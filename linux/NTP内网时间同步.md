### 1. 下载所需ntp包
[download only](YUM#^74cd60)
``` shell
yum -y install ntp
```
### 2. 启动ntpd
``` shell
systemctl start ntpd
```
### 3. 开机启动
``` shell
systemctl enable ntpd
```
### 4. 配置服务端
``` shell
vi /etc/ntp.conf
```

``` shell
# For more information about this file, see the man pages
# ntp.conf(5), ntp_acc(5), ntp_auth(5), ntp_clock(5), ntp_misc(5), ntp_mon(5).
#记录system clock的误差值开机时不会丢失
driftfile /var/lib/ntp/drift

# Permit time synchronization with our time source, but do not
# permit the source to query or modify the service on this system.
#默认拒绝所有来源的任何访问
restrict default nomodify notrap nopeer noquery

# Permit all access over the loopback interface.  This could
# be tightened as well, but to do so would effect some of
# the administrative functions.
#允许本机地址一切操作
restrict 127.0.0.1
restrict ::1

# Hosts on local network are less restricted.
#restrict 192.168.1.0 mask 255.255.255.0 nomodify notrap#restrict 对ntp做权限控制 ignore：忽略所有类型的NTP连接请求 nomodify：限制客户端不能使用命令ntpc和ntpq来修改服务器端的时间#noquery：不提供NTP网络校时服务 notrap：不接受远程登录请求 notrust：不接受没有经过认证的客户端的请求
#允许局域网3网段内所有client连接到这台服务器同步时间.但是拒绝让他们修改服务器上的时间和远程登录
restrict 192.168.3.0 mask 255.255.255.0 nomodify notrap
# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (http://www.pool.ntp.org/join.html).
#server 0.centos.pool.ntp.org iburst
#server 1.centos.pool.ntp.org iburst
#server 2.centos.pool.ntp.org iburst
#server 3.centos.pool.ntp.org iburst

#指定ntp服务器的地址
#将当前主机作为时间服务器
server 192.168.3.11
#时间服务器层级0-15 0表示顶级 10通常用于给局域网主机提供时间服务
fudge 192.168.3.11 stratum 10

#broadcast 192.168.1.255 autokey        # broadcast server
#broadcastclient                        # broadcast client
#broadcast 224.0.1.1 autokey            # multicast server
#multicastclient 224.0.1.1              # multicast client
#manycastserver 239.255.254.254         # manycast server
#manycastclient 239.255.254.254 autokey # manycast client

# Enable public key cryptography.
#crypto

includefile /etc/ntp/crypto/pw

# Key file containing the keys and key identifiers used when operating
# with symmetric key cryptography.
keys /etc/ntp/keys

# Specify the key identifiers which are trusted.
#trustedkey 4 8 42

# Specify the key identifier to use with the ntpdc utility.
#requestkey 8

# Specify the key identifier to use with the ntpq utility.
#controlkey 8

# Enable writing of statistics records.
#statistics clockstats cryptostats loopstats peerstats

# Disable the monitoring facility to prevent amplification attacks using ntpdc
# monlist command when default restrict does not include the noquery flag. See
# CVE-2013-5211 for more details.
# Note: Monitoring will not be disabled with the limited restriction flag.
disable monitor
```

### 5. 重启服务端
``` shell
systemctl restart ntpd
```
### 6. 查看状态
``` shell
[root@tiaf-a ntp]# ntpstat
unsynchronised
  time server re-starting
   polling server every 8 s

```

### 7. 客户端安装及配置
#### 7.1. 仅安装ntpdate即可
#### 7.2. crontab -e

``` shell
*/1 * * * * /sbin/ntpdate -u tiaf-a >/dev/null 2>&1
```
