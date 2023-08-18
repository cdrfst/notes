[参考自](https://www.modb.pro/db/134309)

## 安装
这里可不需安装keepalived
```shell
yum install keepalived haproxy  -y
```

## 修改linux配置

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

## 修改HAProxy配置
```shell
#---------------------------------------------------------------------
# Example configuration for a possible web application.  See the
# full configuration options online.
#
#   http://haproxy.1wt.eu/download/1.4/doc/configuration.txt
#
#---------------------------------------------------------------------
#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    # to have these messages end up in /var/log/haproxy.log you will
    # need to:
    #
    # 1) configure syslog to accept network log events.  This is done
    #    by adding the '-r' option to the SYSLOGD_OPTIONS in
    #    /etc/sysconfig/syslog
    #
    # 2) configure local2 events to go to the /var/log/haproxy.log
    #   file. A line like the following can be added to
    #   /etc/sysconfig/syslog
    #
    #    local2.*                       /var/log/haproxy.log
    #
    log         127.0.0.1 local2
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        root      # 此处要修改成对应的用户，建议用root
    group       root
    daemon
    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats
#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000
#---------------------------------------------------------------------
# main frontend which proxys to the backends
#---------------------------------------------------------------------
frontend rgw *:8080     # 侦听端口
    mode http
    default_backend    rgw
#---------------------------------------------------------------------
# round robin balancing between the various backends
#---------------------------------------------------------------------
backend rgw
    mode http
    balance    source     # 均衡模式，当前为保持会话；轮循模式会有异常
    server rgw1 192.168.3.154:8080 check   # 填写真实网关IP和端口
    server rgw2 192.168.3.155:8080 check
    server rgw3 192.168.3.160:8080 check
```

## 启动服务
```shell
systemctl start haproxy 
systemctl enable haproxy
```
