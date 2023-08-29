## 背景
假设已经存在一个Ceph集群，以下是测试集群部署情况

| Host   | IP            | 服务 |
| ------ | ------------- | ---- |
| asx7-a | 192.168.3.154 | RWG,MON,MGR |
| asx7-b | 192.168.3.155 | RGW,MON,MGR  |
| asx7-c       |192.168.3.160               |MON,MGR      |

## 整体架构

![](Pasted%20image%2020230818155322.png)

## 源码安装
### 安装依赖
```shell
yum -y install gcc
yum -y install openssl-devel --skip-broken
yum install -y libnl3-devel libnfnetlink-devel
```

### 安装Keepalived
```shell
wget http://www.keepalived.org/software/keepalived-2.2.7.tar.gz --no-check-certificate
tar -zxvf keepalived-2.2.7.tar.gz
cd keepalived-2.2.7
./configure --prefix=/usr/local/keepalived
make && make install
```

安装完成，将对应的几个文件cp到/etc目录下

``` shell
mkdir /etc/keepalived/
cp /root/keepalived-2.2.7/keepalived/etc/init.d/keepalived /etc/init.d/
cp /root/keepalived-2.2.7/keepalived/etc/sysconfig/keepalived /etc/sysconfig/
cp /usr/local/keepalived/etc/keepalived/keepalived.conf.sample /etc/keepalived/keepalived.conf
```

### 修改Keepalived配置
- 配置asx7-a 节点
cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak
cat /etc/keepalived/keepalived.conf

```shell
! Configuration File for keepalived

global_defs {
}

vrrp_script chk_rgw {
    script "/usr/local/keepalived/sbin/check_rgw.sh"    # 该脚本检测rgw的运行状态，并在rgw进程挂了之后尝试重新启动rgw，如果启动失败则停止keepalived，准备让其它机器接管。
    interval 2    # 每2s检测一次
    weight 2    # 检测失败（脚本返回非0）则优先级2
}

vrrp_instance VI_1 {
    state MASTER    # 指定keepalived的角色，MASTER表示此主机是主服务器，BACKUP表示此主机是备用服务器
    interface eno16777736    # 指定HA监测网络的接口 根据你实际的网卡名来
    virtual_router_id 55    # 虚拟路由标识，这个标识是一个数字，同一个vrrp实例使用唯一的标识。即同一vrrp_instance下，MASTER和BACKUP必须是一致的
    priority 100    # 定义优先级，数字越大，优先级越高，在同一个vrrp_instance下，MASTER的优先级必须大于BACKUP的优先级
    advert_int 1    # 设定MASTER与BACKUP负载均衡器之间同步检查的时间间隔，单位是秒
    authentication {
        auth_type PASS    # 设置验证类型，主要有PASS和AH两种
        auth_pass dyp    # 设置验证密码，在同一个vrrp_instance下，MASTER与BACKUP必须使用相同的密码才能正常通信
    }
    virtual_ipaddress {
        192.168.3.19/16    # 设置虚拟IP地址，可以设置多个虚拟IP地址，每行一个
    }
    track_script {
        chk_rgw    # 引用VRRP脚本，即在 vrrp_script 部分指定的名字。定期运行它们来改变优先级，并最终引发主备切换。
    }
}
```

/usr/local/keepalived/sbin/check_rgw.sh脚本内容如下：
```shell
#!/bin/bash
if [ "$(ps -ef | grep "radosgw"| grep -v grep )" == "" ];then
    systemctl start ceph-radosgw.target 
    sleep 3

    if [ "$(ps -ef | grep "radosgw"| grep -v grep )" == "" ];then
        systemctl stop keepalived
    fi
fi
```

添加check_rgw.sh脚本执行权限：
```shell
chmod +x /usr/local/keepalived/sbin/check_rgw.sh
```

- 配置asx7-b 节点
cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak
cat /etc/keepalived/keepalived.conf

```shell
! Configuration File for keepalived

global_defs {
}

vrrp_script chk_rgw {
    script "/usr/local/keepalived/sbin/check_rgw.sh"
    interval 2
    weight 2
}

vrrp_instance VI_1 {
    state BACKUP
    interface eno16777736
    virtual_router_id 55
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass dyp
    }
    virtual_ipaddress {
        192.168.3.19/16
    }
    track_script {
        chk_rgw
    }
}
```

check_rgw.sh 脚本赋予权限，同上一个节点

### 启动Keepalived
启动 asx7-a和asx7-b两个节点的服务
**启动前记得修改配置文件中的interface**

```shell
systemctl start keepalived
```

此时在asx7-a节点执行 `` ip a ``可以看到目前地址(192.168.3.19)是在此节点上
```shell
[root@asx7-a ~]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 8a:54:80:f1:7f:56 brd ff:ff:ff:ff:ff:ff
    inet 192.168.3.154/24 brd 192.168.3.255 scope global noprefixroute dynamic eth0
       valid_lft 73244sec preferred_lft 73244sec
    inet 192.168.3.19/16 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::18c:7d1e:fed8:d465/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

此时将 asx7-a节点的RGW服务停止来模拟故障
``` shell
systemctl stop ceph-radosgw.target
```

再在两个节点执行`` ip a `` 发现IP已经漂移到asx7-b上

由始至终 访问 http://192.168.3.19:8080 都可以正常访问.

[引用自](https://ypdai.github.io/2021/02/24/keepalived+RGW/)
