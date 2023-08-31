[参考自](https://blog.csdn.net/weixin_51867896/article/details/124229787)

## 编译环境
### 安装LUA
HAProxy要求的lua最低版本(5.3)的要求
```shell
[root@asx7-d ~]# lua -v
Lua 5.1.4  Copyright (C) 1994-2008 Lua.org, PUC-Rio
```

```shell
yum install gcc readline-devel -y
tar xvf lua-5.4.4.tar.gz -C /usr/local/src
cd /usr/local/src/lua-5.4.4/
make linux test
```
查看编译的lua版本
```shell
[root@asx7-d lua-5.4.4]# src/lua -v
Lua 5.4.4  Copyright (C) 1994-2022 Lua.org, PUC-Rio
```

## 编译安装HAProxy

```shell
yum -y install gcc openssl-devel pcre-devel systemd-devel
tar xvf haproxy-2.4.18.tar.gz -C /usr/local/src
cd /usr/local/src/haproxy-2.4.18

#查看安装方法
less INSTALL 
less Makefile

#参考INSTALL文件进行编译安装
make ARCH=x86_64 TARGET=linux-glibc USE_PCRE=1 USE_OPENSSL=1 USE_ZLIB=1 USE_SYSTEMD=1 USE_LUA=1 LUA_INC=/usr/local/src/lua-5.4.4/src/ LUA_LIB=/usr/local/src/lua-5.4.4/src/

make install PREFIX=/apps/haproxy
ln -s /apps/haproxy/sbin/haproxy /usr/sbin/
```
### 验证
```shell
[root@asx7-d ~]# haproxy -v
HAProxy version 2.4.18-1d80f18 2022/07/27 - https://haproxy.org/
Status: long-term supported branch - will stop receiving fixes around Q2 2026.
Known bugs: http://www.haproxy.org/bugs/bugs-2.4.18.html
Running on: Linux 3.10.0-957.axs7.x86_64 #1 SMP Thu May 9 10:22:45 UTC 2019 x86_64

```

## 准备启动文件

创建service文件
```shell
vim /usr/lib/systemd/system/haproxy.service
```

```shell
[Unit]
Description=HAProxy Load Balancer
After=syslog.target network.target

[Service]
ExecStartPre=/usr/sbin/haproxy -f /etc/haproxy/haproxy.cfg -c -q
ExecStart=/usr/sbin/haproxy -Ws -f /etc/haproxy/haproxy.cfg -p /var/lib/haproxy/haproxy.pid
ExecReload=/bin/kill -USR2 $MAINPID
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
```

重新加载 systemd 守护进程的命令。当你对 systemd 的配置文件进行修改后，需要运行这个命令来通知 systemd 重新加载配置，以使更改生效。
```shell
systemctl daemon-reload
```
## 修改linux配置(非必须)

选取两个均衡节点(均衡节点不能和rgw节点重合)，下面在均衡节点（LB）执行。

开启linux ip转发功能

```
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p
```

允许绑定到非本地ip

```
echo "net.ipv4.ip_nonlocal_bind = 1" >> /etc/sysctl.conf
sysctl -p
```

**检查 ：**

```
/usr/sbin/sysctl net.ipv4.ip_nonlocal_bind
/usr/sbin/sysctl net.ipv4.ip_forward
cat /proc/sys/net/ipv4/ip_forward
```

查看是否看起了ip转发功能  
如果上述文件中的值为0,说明禁止进行IP转发；如果是1,则说明IP转发功能已经打开。
**其实经过测试不配置上面的 IP转发和允许绑定到非本地IP 对负载均衡也没啥影响**

## HAProxy配置
### 创建HAProxy配置文件
```shell
mkdir /etc/haproxy
vim /etc/haproxy/haproxy.cfg
```

```shell
global
    maxconn 100000
    chroot /apps/haproxy
    stats socket /var/lib/haproxy/haproxy.sock mode 600 level admin
    #uid 99
    #gid 99
    user haproxy
    group haproxy
    daemon
    #nbproc 4
    #cpu-map 1 0
    #cpu-map 2 1
    #cpu-map 3 2
    #cpu-map 4 3
    pidfile /var/lib/haproxy/haproxy.pid
    #log 127.0.0.1 local2 info
    log 127.0.0.1 local3 info


defaults
    option http-keep-alive
    option forwardfor
    maxconn 100000
    mode http
    timeout connect 300000ms
    timeout client 300000ms
    timeout server 300000ms

listen stats
    mode http
    bind 0.0.0.0:9999
    stats enable
    log global
    stats uri /haproxy-status
    stats auth haadmin:123456

listen web_port
    bind 0.0.0.0:80
    mode http
    log global
    server web1 127.0.0.1:8080 check inter 3000 fall 2 rise 5

#---------------------------------------------------------------------
# main frontend which proxys to the backends
#---------------------------------------------------------------------
frontend rgw
    bind *:8080     # 侦听端口
    mode http
    log global
    default_backend    rgw
#---------------------------------------------------------------------
# round robin balancing between the various backends
#---------------------------------------------------------------------
backend rgw
    mode http
    log global
    balance    source     # 均衡模式，当前为保持会话；轮循模式会有异常
    server rgw1 192.168.3.154:8080 check   # 填写真实网关IP和端口
    server rgw2 192.168.3.155:8080 check
    server rgw3 192.168.3.160:8080 check

```
**以上配置80和8080端口指向同一组后端服务器**

### 配置HAProxy日志(按需)
1. 修改rsyslog.conf
vi /etc/rsyslog.conf(添加如下内容)  
```shell
# provides UDP syslog reception
module(load="imudp")
input(type="imudp" port="514")
local3.* /var/log/haproxy.log
```
**注意给日志文件 赋予响应权限，否则无法生成**

2. 修改rsyslog
vi /etc/sysconfig/rsyslog
把SYSLOGD_OPTIONS="-m 0"  
改成以下:
```shell
SYSLOGD_OPTIONS="-r -m 0 -c 2"
```

**相关解释说明:
-r:打开接受外来日志消息的功能,其监控514 UDP端口;
-x:关闭自动解析对方日志服务器的FQDN信息,这能避免DNS不完整所带来的麻烦;
-m:修改syslog的内部mark消息写入间隔时间(0为关闭),例如240为每隔240分钟写入一次"--MARK--"信息;
-h:默认情况下,syslog不会发送从远端接受过来的消息到其他主机,而使用该选项,则把该开关打开,所有
接受到的信息都可根据syslog.conf中定义的@主机转发过去**

配置完毕后重启rsyslogd和haproxy即可.
3. 重启服务
```shell
systemctl restart rsyslog
systemctl restart haproxy

```
## 启动服务
```shell
systemctl enable --now haproxy
```
