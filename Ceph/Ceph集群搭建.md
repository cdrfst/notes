
## 一、必备条件
### 1. python3

引用地址: https://blog.csdn.net/QIU176161650/article/details/118784155

``` shell
#下载编译环境
sudo yum install -y --downloadonly --downloaddir=/home/tiaf/python3pkgs zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel  gcc  libffi-devel
#安装
sudo yum localinstall *.rpm

#下载python3
wget -P /root/offline_env_file/python3 https://www.python.org/ftp/python/3.9.6/Python-3.9.6.tar.xz

#解压
tar xf Python-3.9.6.tar.xz

#创建目录
mkdir /usr/local/python3.9.6

#编译
sudo ./configure --prefix=/usr/local/python3.9.6 &&sudo make &&sudo make install

#备份旧版链接
mv /usr/bin/python /usr/bin/python2
mv /usr/bin/pip /usr/bin/pip2

#创建新版链接
ln -sf /usr/local/python3.9.6/bin/python3 /usr/bin/python3
ln -sf /usr/bin/python3 /usr/bin/python
ln -sf /usr/local/python3.9.6/bin/pip3 /usr/bin/pip3
ln -sf /usr/bin/pip3 /usr/bin/pip

#修改yum命令的配置文件（yum命令默认为Python2来执行），这里需要修改两个配置文件/usr/bin/yum 和 /usr/libexec/urlgrabber-ext-down  修改文件第一行内容，如下所示
#!/usr/bin/python  修改为 #!/usr/bin/python2

```



## 关闭selinux和防火墙

``` shell
#selinux 
vi /etc/selinux/config
#关闭防火墙
systemctl stop firewalld & systemctl disable firewalld & systemctl status firewalld
```
## 内网时间同步到秒

https://www.cnblogs.com/xiongty/p/14886447.html

## 新建用户
## 加入sudoers
## 配置互信

## 二、配置离线yum仓库

### 下载离线源文件

- x86
```shell
#!/usr/bin/env bash

URL_REPO=https://mirrors.tuna.tsinghua.edu.cn/ceph/rpm-15.2.17/el7/x86_64/
URL_REPODATA=https://mirrors.tuna.tsinghua.edu.cn/ceph/rpm-15.2.17/el7/x86_64/repodata/

function get_repo()
{
test -d ceph_repo || mkdir ceph_repo
cd ceph_repo

for i in `curl -k $URL_REPO | awk -F '"' '{print $4}' | grep rpm`;do
    curl -kO $URL_REPO/$i
done
}

function get_repodata()
{
test -d ceph_repo/repodata || mkdir ceph_repo/repodata
cd ceph_repo/repodata

for i in `curl -k $URL_REPODATA | awk -F '"' '{print $4}' | grep xml`;do
    curl -kO $URL_REPODATA/$i
done
}

if [ $1 == 'repo' ];then 
    get_repo
elif [ $1 == 'repodata' ];then
    get_repodata
elif [ $1 == 'all' ];then
    get_repo
    get_repodata
else
    echo '请输入其中一个参数[ repo | repodata | all ]'
fi

```
- aarch64
```shell
#!/usr/bin/env bash

URL_REPO=https://mirrors.tuna.tsinghua.edu.cn/ceph/rpm-15.2.17/el7/aarch64/
URL_REPODATA=https://mirrors.tuna.tsinghua.edu.cn/ceph/rpm-15.2.17/el7/aarch64/repodata/

function get_repo()
{
test -d ceph_repo || mkdir ceph_repo
cd ceph_repo

for i in `curl -k $URL_REPO | awk -F '"' '{print $4}' | grep rpm`;do
    curl -kO $URL_REPO/$i
done
}

function get_repodata()
{
test -d ceph_repo/repodata || mkdir ceph_repo/repodata
cd ceph_repo/repodata

for i in `curl -k $URL_REPODATA | awk -F '"' '{print $4}' | grep xml`;do
    curl -kO $URL_REPODATA/$i
done
}

if [ $1 == 'repo' ];then 
    get_repo
elif [ $1 == 'repodata' ];then
    get_repodata
elif [ $1 == 'all' ];then
    get_repo
    get_repodata
else
    echo '请输入其中一个参数[ repo | repodata | all ]'
fi

```
- noarch
```shell
#!/usr/bin/env bash

URL_REPO=https://mirrors.tuna.tsinghua.edu.cn/ceph/rpm-15.2.17/el7/noarch/
URL_REPODATA=https://mirrors.tuna.tsinghua.edu.cn/ceph/rpm-15.2.17/el7/noarch/repodata/

function get_repo()
{
test -d ceph_repo || mkdir ceph_repo
cd ceph_repo

for i in `curl -k $URL_REPO | awk -F '"' '{print $4}' | grep rpm`;do
    curl -kO $URL_REPO/$i
done
}

function get_repodata()
{
test -d ceph_repo/repodata || mkdir ceph_repo/repodata
cd ceph_repo/repodata

for i in `curl -k $URL_REPODATA | awk -F '"' '{print $4}' | grep xml`;do
    curl -kO $URL_REPODATA/$i
done
}

if [ $1 == 'repo' ];then 
    get_repo
elif [ $1 == 'repodata' ];then
    get_repodata
elif [ $1 == 'all' ];then
    get_repo
    get_repodata
else
    echo '请输入其中一个参数[ repo | repodata | all ]'
fi

```

以上脚本会生成离线安装源文件分别是：
ceph_x86_repo.gtz 、ceph_noarch_repo.gtz、ceph_arm_repo.gtz

### 安装Nginx
安装nginx后启动，将上一步的三个离线包分别解压到nginx的默认根目录测试能访问即可

### 配置yum源
ceph-http-diy.repo
```shell
[ceph]
name=Ceph packages for 
baseurl=http://127.0.0.1/ceph_x86_repo
enabled=1
priority=1
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc

[ceph-noarch]
name=Ceph noarch packages
baseurl=http://127.0.0.1/ceph_noarch_repo
enabled=1
priority=1
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc

```


## 三、安装Ceph (Centos7 or RH7 or Asianux7)

https://www.cnblogs.com/weiwei2021/p/14060186.html

``` shell
#一、直接安装
sudo yum install -y ceph

#二、也可制作离线ceph安装包 (离线安装下面包时还会自动下载一些依赖,如环境不同需要每台单独执行)
sudo yum -y install --downloadonly --downloaddir=/home/tiaf/cephcentos7/ceph/ ceph  ceph-radosgw

#2.1.本地安装
sudo yum localinstall *.rpm
```


#### 遇到的问题

``` shell
[rh74tiafceph02][DEBUG ] connection detected need for sudo
sudo: no tty present and no askpass program specified
[ceph_deploy][ERROR ] RuntimeError: connecting to host: rh74tiafceph02 resulted in errors: IOError cannot send (already closed?)
```

#### 解决办法
``` shell
sudo visudo

#添加
tiaf    ALL=(ALL)  NOPASSWD:ALL
```


## 统信uos1050e
### 准备一台可访问外网的服务器环境生成离线安装包

### 参照官方手动部署


### 遇到的问题

1. 添加 ceph源文件 cephcentos7.repo 及epel 源wget -O /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo
2. 利用自带chrony 配置时间同步 涉及 server 端 和客户端配置文件  /etc/chrony.conf
``` shell
# 部署ceph-deploy 在线
pip install ceph-deploy

```
部署ceph-deploy遇到的问题
``` shell
Error:
 Problem: cannot install the best candidate for the job
  - nothing provides python-argparse needed by ceph-deploy-2.0.1-0.noarch
```
解决方法：
``` shell
yum install python3
wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py

```

## 红旗7.6(x86环境成功安装)

1. python3
2. 下载epel repo
``` shell
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

su -c 'rpm -Uvh https://download.ceph.com/rpm-15.2.5/el7/noarch/ceph-release-1-1.el7.noarch.rpm'

su -c 'rpm -Uvh https://download.ceph.com/rpm-15.2.5/el7/noarch/ceph-deploy-2.0.1-0.noarch.rpm'

sudo yum -y install --downloadonly --downloaddir=/home/tiaf/offline/ceph/ ceph  ceph-radosgw

```



1. 下载cephadm
``` shell
curl --silent --remote-name --location https://github.com/ceph/ceph/raw/quincy/src/cephadm/cephadm
chmod +x cephadm
```

2. 通过 ceph和版本号配置 仓库
``` shell
sudo ./cephadm add-repo --version 15.2.17
```

1. 安装
``` shell
#需要先导入一个GPG key 否则无法安装
#此为rpm方式,apt方式请参照官方文档:https://docs.ceph.com/en/latest/install/get-packages/
sudo rpm --import 'https://download.ceph.com/keys/release.asc'
sudo ./cephadm install ceph-common
sudo ./cephadm install
#检查是否成功
which cephadm
```

### 离线安装前尝试

#### 配置Ceph本地源

[可以参考](http://dbaselife.com/doc/753/)

1. 通过以下脚本下载各源文件
2. 配置nginx
3. 新增本地源配置文件
``` shell
#!/usr/bin/env bash

URL_REPO=https://mirrors.tuna.tsinghua.edu.cn/ceph/rpm-15.2.17/el7/x86_64/
URL_REPODATA=https://mirrors.tuna.tsinghua.edu.cn/ceph/rpm-15.2.17/el7/x86_64/repodata/

function get_repo()
{
test -d ceph_repo || mkdir ceph_repo
cd ceph_repo

for i in `curl $URL_REPO | awk -F '"' '{print $4}' | grep rpm`;do
    curl -O $URL_REPO/$i
done
}

function get_repodata()
{
test -d ceph_repo/repodata || mkdir ceph_repo/repodata
cd ceph_repo/repodata

for i in `curl $URL_REPODATA | awk -F '"' '{print $4}' | grep xml`;do
    curl -O $URL_REPODATA/$i
done
}

if [ $1 == 'repo' ];then 
    get_repo
elif [ $1 == 'repodata' ];then
    get_repodata
elif [ $1 == 'all' ];then
    get_repo
    get_repodata
else
    echo '请输入其中一个参数[ repo | repodata | all ]'
fi

```

``` shell
cat > /etc/yum.repos.d/ceph-http.repo << EOF
[local-ceph]
name=local-ceph
baseurl=http://asianux76-a/ceph_x86_repo
gpgcheck=0
enable=1
[noarch-ceph]
name=local-ceph
baseurl=http://asianux76-a/ceph_noarch_repo
gpgcheck=0
enable=1
EOF
```
#### 安装ceph-deploy 2.0.1

基于python2.7.5 离线

``` shell
## ceph需要的python环境依赖，一并装上(所有节点？)
yum -y install ceph-common python-pkg-resources python-setuptools python2-subprocess32

## 装deploy
yum -y install ceph-deploy-2.0.1

## 安装完毕后，可以查看帮助命令
ceph-deploy --help

```

安装了pip for python2

#### 集群初始化部署

``` shell
## 初始化之前，最好提前在每个 mon 节点都将mon的包安装好，在之后的安装中程序会自动安装，提前装好是为了提前发现问题 
yum -y install ceph-mon

# 执行此命令前需要将system-release文件内容换成redhat/centos7的，否则提示不支持
ceph-deploy new --cluster-network 192.168.3.0/8 --public-network 192.168.3.0/8 asianux76-a

#初始化mon节点
ceph-deploy mon create-initial
# 验证初始化完成
ps -ef | grep ceph-mon

#将配置文件及Admin的key传送至目标机器,到目前只有一个mon (sudo ceph -s 可查看)
ceph-deploy admin asianux76-a asianux76-b

# 添加mgr,每个节点都要装
sudo yum -y install ceph-mgr

#添加mgr至集群
ceph-deploy mgr create asianux76-a

#初始化osd
## 查看目标主机可用磁盘
ceph-deploy disk list asianux76-a
## 初始化node节点，其实就是安装ceph、ceph-radosgw和一些相关基础组件
ceph-deploy install --no-adjust-repos --nogpgcheck asianux76-a asianux76-b
    --no-adjust-repos表示不将本机的repo文件传输至目标机器，因为前边已经手动配置了
    --nogpgcheck不检查yum的key

## 在需要安装osd的机器中执行
sudo yum -y install ceph-osd ceph-common

# 擦除所有node节点要初始化为osd的盘的数据
ceph-deploy disk zap ceph-node1 /dev/nvme0n1p3 /dev/nvme0n1p4 /dev/nvme0n1p5
# 开始创建osd
## 举例，其他盘也要相同的操作
ceph-deploy osd create asianux76-a --data /dev/sdb
ceph-deploy osd create asianux76-b --data /dev/sdb


```
至此，基本的ceph集群已经搭建成功，rbd功能已经可以开始使用。
另外如果想要开启对象存储以及文件系统的功能，还需要部署rgw、mds和cephfs。此时的mon、mgr等组件都没实现高可用，先进行这些重要组件的横向扩展。

``` shell
# 扩展mon节点
## 目标机器先安装ceph-mon组件
sudo yum -y install ceph-mon ceph-common
## 添加mon机器
ceph-deploy mon add asianux76-b

# 扩展mgr节点
## 目标机器先安装ceph-mgr组件
sudo yum -y install ceph-mgr ceph-common
## 添加mgr机器
ceph-deploy mgr create asianux76-b
```

增加mds(元数据服务)、cephfs提供文件系统功能

mds服务为一个单独存储服务，想要正常运行必须要单独指定两个存储池，一个用来存储cephfs的元数据，另一个用来存储data数据，元数据池主要保存文件目录的大小名称等元数据，data池用来保存实际文件等。

``` shell
#HTTPFSUSER 
ceph-deploy mds create asianux76-a
ceph-deploy mds create asianux76-b

#查看Ceph状态
[tiaf@asianux76-a ~]$ sudo ceph -s
  cluster:
    id:     83ba32ef-935d-4303-aaed-e97c549b573a
    health: HEALTH_WARN
            mons are allowing insecure global_id reclaim
            Module 'restful' has failed dependency: No module named 'pecan'
            clock skew detected on mon.asianux76-b
            Reduced data availability: 1 pg inactive
            Degraded data redundancy: 1 pg undersized
            1 slow ops, oldest one blocked for 198 sec, mon.asianux76-a has slow ops
            OSD count 2 < osd_pool_default_size 3

  services:
    mon: 2 daemons, quorum asianux76-a,asianux76-b (age 6m)
    mgr: asianux76-a(active, since 40m), standbys: asianux76-b
    mds:  2 up:standby
    osd: 2 osds: 2 up (since 14m), 2 in (since 14m)

  data:
    pools:   1 pools, 1 pgs
    objects: 0 objects, 0 B
    usage:   2.0 GiB used, 8.0 GiB / 10 GiB avail
    pgs:     100.000% pgs not active
             1 undersized+peered
#目前mds已经加入集群，但是都处于standby(备用)状态，因为mds必须要分别指定元数据和数据的存储池：

## 先创建元数据池和data池，后边是数据分别得pg和pgp的数量
ceph osd pool create cephfs-metedata 32 32 
ceph osd pool create cephfs-data 64 64 
#此处报错:(在最上面把pip安装后此问题已经解决)
[errno 2] RADOS object not found (error connecting to the cluster)
#解决办法：先把sudo ceph -s 中的警告信息处理完
 cluster:
    id:     83ba32ef-935d-4303-aaed-e97c549b573a
    health: HEALTH_WARN
            mons are allowing insecure global_id reclaim
            Module 'restful' has failed dependency: No module named 'pecan'
            clock skew detected on mon.asianux76-b
            Reduced data availability: 1 pg inactive
            Degraded data redundancy: 1 pg undersized
            1 slow ops, oldest one blocked for 306 sec, mon.asianux76-a has slow ops
            OSD count 2 < osd_pool_default_size 3

##1.找不到模块 'pecan' 
当前系统默认python2.7.5 ，首先安装pip
下载安装脚本:https://bootstrap.pypa.io/pip/2.7/get-pip.py
#执行安装pip
python get-pip.py
#重启机器后 sudo ceph -s卡住不动(在最上面把pip安装后此问题已经解决)



ceph osd lspools 
1 device_health_metrics
2 cephfs-metedata
3 cephfs-data


#创建cephfs
ceph fs new mycephfs cephfs-metedata cephfs-data
##成功后两次ceph -s 发现mds状态变正常,到此cephfs功能搭建完毕

#增加rgw组件，提供对象存储功能
yum -y install ceph-radosgw
#部署
ceph-deploy --overwrite-conf rgw create asianux76-a
ceph-deploy --overwrite-conf rgw create asianux76-b


```

### 按官网手动安装尝试


#### Add Keys
```
rpm --import 'https://download.ceph.com/keys/release.asc'
```
包源地址：
https://download.ceph.com/rpm-15.2.17/el7/x86_64/
https://download.ceph.com/rpm-15.2.17/el7/aarch64/
https://download.ceph.com/rpm-15.2.17/el7/noarch/
搭建本地仓库省略
配置ceph.repo

To install Ceph with RPMs, execute the following steps:

1.  Install `yum-plugin-priorities`.
    
    sudo yum install yum-plugin-priorities
    
2.  Ensure `/etc/yum/pluginconf.d/priorities.conf` exists.
    
3.  Ensure `priorities.conf` enables the plugin.
    
    [main]
    enabled = 1
    
4.  Ensure your YUM `ceph.repo` entry includes `priority=2`. See [Get Packages](https://docs.ceph.com/en/latest/install/get-packages) for details:
``` shell
[ceph]
name=Ceph packages for $basearch
baseurl=https://download.ceph.com/rpm-{ceph-release}/{distro}/$basearch
enabled=1
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc

[ceph-noarch]
name=Ceph noarch packages
baseurl=https://download.ceph.com/rpm-{ceph-release}/{distro}/noarch
enabled=1
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc

[ceph-source]
name=Ceph source packages
baseurl=https://download.ceph.com/rpm-{ceph-release}/{distro}/SRPMS
enabled=0
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc
```
5. Install pre-requisite packages:
```shell
sudo yum install snappy leveldb gdisk python-argparse gperftools-libs
```
如果安装argparse出错则``pip install argparse


Once you have added either release or development packages, or added a `ceph.repo` file to `/etc/yum.repos.d`, you can install Ceph packages.
```shell
sudo yum install ceph
```
此步骤需要arm系统环境 在红旗7.6 x86中需要92个rpm包

#### 手动部署
https://docs.ceph.com/en/octopus/install/manual-deployment/
##### 执行第15步骤时报错
```shell
sudo -u ceph ceph-mon --mkfs -i ceph-asianux76-a --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring
global_init: error reading config file.

```
原因是需要在/etc/ceph/ceph.conf文件中最头部加个"[global]"的section

#### 配置mon
[官方文档](https://docs.ceph.com/en/octopus/install/manual-deployment/#monitor-bootstrapping)

```shell
#8.生成集群密钥环和mon密钥
ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'

#9.Generate an administrator keyring, generate a `client.admin` user and add the user to the keyring.
sudo ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'

#10.Generate a bootstrap-osd keyring, generate a `client.bootstrap-osd` user and add the user to the keyring.
sudo ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd' --cap mgr 'allow r'

#11.Add the generated keys to the `ceph.mon.keyring`.
sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring

#12.Change the owner for `ceph.mon.keyring`.
sudo chown ceph:ceph /tmp/ceph.mon.keyring

#13.Generate a monitor map using the hostname(s), host IP address(es) and the FSID. Save it as `/tmp/monmap`:
##monmaptool --create --add {hostname} {ip-address} --fsid {uuid} /tmp/monmap
monmaptool --create --add `hostname -s` 192.168.3.21 --fsid a7f64266-0894-4f1e-a635-d0aeaca0e993 /tmp/monmap

#14.Create a default data directory (or directories) on the monitor host(s).
##sudo mkdir /var/lib/ceph/mon/{cluster-name}-{hostname}
sudo -u ceph mkdir /var/lib/ceph/mon/ceph-asianux76-a

#15.Populate the monitor daemon(s) with the monitor map and keyring.
##sudo -u ceph ceph-mon [--cluster {cluster-name}] --mkfs -i {hostname} --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring
sudo -u ceph ceph-mon --mkfs -i `hostname -s` --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring

#16.检查/etc/ceph/ceph.conf

#17.启动mon服务
sudo systemctl start ceph-mon@`homename -s`

#18.查看ceph集群状态
ceph -s

```


#### 配置osd
https://docs.ceph.com/en/octopus/install/manual-deployment/#adding-osds
OSD存储后端分为 BLUESTORE 和 FILESTORE两种，每种都有快速和分步部署，此处仅使用 BLUESTORE的快速部署
bluestore[¶](https://docs.ceph.com/en/octopus/glossary/#term-bluestore "Permalink to this term")
OSD BlueStore is a new back end for OSD daemons (kraken and newer versions). Unlike [filestore](https://docs.ceph.com/en/octopus/glossary/#term-filestore) it stores objects directly on the Ceph block devices without any file system interface.

bluestore[¶](https://docs.ceph.com/en/octopus/glossary/#term-bluestore "Permalink to this term")
OSD BlueStore is a new back end for OSD daemons (kraken and newer versions). Unlike [filestore](https://docs.ceph.com/en/octopus/glossary/#term-filestore) it stores objects directly on the Ceph block devices without any file system interface.

```shell
# BLUESTORE
ssh asianux76-a
sudo ceph-volume lvm create --data /dev/hdd1

# FILESTORE
```

#### 配置mgr
https://docs.ceph.com/en/octopus/mgr/administrator/
The Ceph manager software, which collects all the state from the whole cluster in one place.
非必须！但官方推荐最好在每台mon的节点上配置一个mgr

```shell
#创建数据目录
sudo -u ceph mkdir /var/lib/ceph/mgr/ceph-`hostname -s`
cd /var/lib/ceph/mgr/ceph-`hostname -s`

#创建密钥
ceph auth get-or-create mgr.`hostname -s` mon 'allow profile mgr' osd 'allow *' mds 'allow *' > keyring
#此处注意keyring文件的所有者和所属组为ceph
#启动
ceph-mgr -i `hostname -s`

```

#### 配置Ceph Object Gateway
https://zhuanlan.zhihu.com/p/441588192

1. 安装radosgw
```shell
yum install ceph-radosgw -y

```
2. 建rgw相关资源池
资源池列表及部分资源池功能介绍如下。

-   .rgw:region和zone配置信息。  
    
-   .rgw.root:region和zone配置信息。  
    
-   .rgw.control：存放notify信息。  
    
-   .rgw.gc：用于资源回收。  
    
-   .rgw.buckets：存放数据。  
    
-   .rgw.buckets.index：存放元数据信息。  
    
-   .rgw.buckets.extra：存放元数据扩展信息。  
    
-   .log：日志存放。  
    
-   .intent-log：日志存放。  
    
-   .usage：存放用户已用容量信息。  
    
-   .users：存放用户信息。  
    
-   .users.email：存放用户E-mail信息。  
    
-   .users.swift：存放swift类型的账号信息。  
    
-   .users.uid：存放用户信息。

```shell
ceph osd pool create .rgw 8 8
ceph osd pool create .rgw.root 8 8
ceph osd pool create .rgw.control 8 8
ceph osd pool create .rgw.gc 8 8
ceph osd pool create .rgw.buckets 8 8
ceph osd pool create .rgw.buckets.index 8 8
ceph osd pool create .rgw.buckets.extra 8 8
ceph osd pool create .log 8 8
ceph osd pool create .intent-log 8 8
ceph osd pool create .usage 8 8
ceph osd pool create .users 8 8
ceph osd pool create .users.email 8 8
ceph osd pool create .users.swift 8 8
ceph osd pool create .users.uid 8 8

```
创建过程会遇到这个报错，原因是每个osd默认最多只支持250个pg，这里有两种解决办法，一种是删除之前创建的pool，并新建pool时把pg设置小一点，另一种则是修改osd默认最大pg数，这里我用了第二种，修改完配置文件后，重启mon

> Error ERANGE: pg_num 8 size 3 would mean 771 total pgs, which exceeds max 750 (mon_max_pg_per_osd 250 * num_in_osds 3)

编辑配置文件

```text
vim /etc/ceph/ceph.conf
[global]
mon_max_pg_per_osd = 1000

#重启mon
systemctl restart ceph-mon@`hostname -s`
```

可以使用`rados lspools`查看是否创建成功


```shell
#创建keying
ceph-authtool --create-keyring /etc/ceph/ceph.client.radosgw.keyring
chown ceph:ceph /etc/ceph/ceph.client.radosgw.keyring


#生成ceph-radosgw服务对应的用户和key

ceph-authtool /etc/ceph/ceph.client.radosgw.keyring -n client.rgw.`hostname -s` --gen-key
#ceph-authtool /etc/ceph/ceph.client.radosgw.keyring -n client.rgw.node2 --gen-key
#ceph-authtool /etc/ceph/ceph.client.radosgw.keyring -n client.rgw.node3 --gen-key

# 添加用户访问权限
ceph-authtool -n client.rgw.`hostname -s` --cap osd 'allow rwx' --cap mon 'allow rwx' /etc/ceph/ceph.client.radosgw.keyring
#ceph-authtool -n client.rgw.node2 --cap osd 'allow rwx' --cap mon 'allow rwx' /etc/ceph/ceph.client.radosgw.keyring
#ceph-authtool -n client.rgw.node3 --cap osd 'allow rwx' --cap mon 'allow rwx' /etc/ceph/ceph.client.radosgw.keyring

#将keyring导入集群中
ceph -k /etc/ceph/ceph.client.admin.keyring auth add client.rgw.`hostname -s` -i /etc/ceph/ceph.client.radosgw.keyring
#ceph -k /etc/ceph/ceph.client.admin.keyring auth add client.rgw.node2 -i /etc/ceph/ceph.client.radosgw.keyring
#ceph -k /etc/ceph/ceph.client.admin.keyring auth add client.rgw.node3 -i /etc/ceph/ceph.client.radosgw.keyring

#编辑配置文件
cat >> /etc/ceph/ceph.conf << EOF
[client.rgw.`hostname -s`]
host=`hostname -s`
keyring=/etc/ceph/ceph.client.radosgw.keyring
log file=/var/log/radosgw/client.radosgw.gateway.log
rgw_frontends = civetweb port=8080

以下根据实际修改

[client.rgw.node2]
host=node2
keyring=/etc/ceph/ceph.client.radosgw.keyring
log file=/var/log/radosgw/client.radosgw.gateway.log
rgw_frontends = civetweb port=8080
[client.rgw.node3]
host=node3
keyring=/etc/ceph/ceph.client.radosgw.keyring
log file=/var/log/radosgw/client.radosgw.gateway.log
rgw_frontends = civetweb port=8080
EOF

#创建日志目录
mkdir /var/log/radosgw
chown ceph:ceph /var/log/radosgw
#启动rgw服务
systemctl start ceph-radosgw@rgw.`hostname -s` && systemctl enable ceph-radosgw@rgw.`hostname -s`

```
此时存在以下错误和警告:
```shell
[root@asianux76-a ceph]# ceph -s
  cluster:
    id:     a7f64266-0894-4f1e-a635-d0aeaca0e993
    health: HEALTH_WARN
            mon is allowing insecure global_id reclaim
            Module 'restful' has failed dependency: No module named 'pecan'
            1 monitors have not enabled msgr2
            1 pool(s) do not have an application enabled
            Reduced data availability: 449 pgs inactive
            Degraded data redundancy: 449 pgs undersized

  services:
    mon: 1 daemons, quorum asianux76-a (age 17h)
    mgr: asianux76-a(active, since 19h)
    osd: 3 osds: 3 up (since 19h), 3 in (since 19h)

  data:
    pools:   15 pools, 449 pgs
    objects: 0 objects, 0 B
    usage:   3.0 GiB used, 33 GiB / 36 GiB avail
    pgs:     100.000% pgs not active
             449 undersized+peered

```
1. 错误:"Module 'restful' has failed dependency: No module named 'pecan'"
此时已经自动安装了python3.6
安装相应的python模块
解决：``pip3 install pecan werkzeug


注意，这里需要使用pip3进行安装，否则不生效，如果安装完成之后还存在问题，需要重启系统生效。  
这里还需要安装`werkzeug`模块

2. 错误:"monitors have not enabled msgr2";此问题在后续扩展添加的mon中可能还会存在,暂未找到完美解决办法
[https://docs.ceph.com/en/pacific/rados/configuration/msgr2/](https://docs.ceph.com/en/pacific/rados/configuration/msgr2/)  [https://docs.ceph.com/en/pacific/rados/operations/health-checks/#mon-msgr2-not-enabled](https://docs.ceph.com/en/pacific/rados/operations/health-checks/#mon-msgr2-not-enabled) 

解决：``ceph mon enable-msgr2

3. 错误：“mons are allowing insecure global_id reclaim”  
解决：``ceph config set mon auth_allow_insecure_global_id_reclaim false

4. 错误：“Reduced data availability: 449 pgs inactive Degraded data redundancy: 449 pgs undersized” 
此错误会导致8080端口无法访问.
解决： "_If you are trying to create a cluster on a single node, you must change the default of the osd crush chooseleaf type setting from 1 (meaning host or node) to 0 (meaning osd) in your Ceph configuration file before you create your monitors and OSDs._"
在/etc/ceph/ceph.conf 添加配置:

```shell
osd crush chooseleaf type = 0 #默认值为1
```

5. 错误：“1 pool(s) do not have an application enabled”
解决：先执行``ceph health detail  
查看详情，再根据提示进行 enable 即可,

```shell
#例：
#use 'ceph osd pool application enable <pool-name> <app-name>', where <app-name> is 'cephfs', 'rbd', 'rgw', or freeform for custom applications.
ceph osd pool application enable .rgw.root rgw
```


#### 客户端访问
[参考](http://dbaselife.com/project-3/doc-306/)

##### S3
[官方文档](https://docs.ceph.com/en/octopus/radosgw/admin/)

```shell
#创建用户
radosgw-admin user create --uid=johndoe --display-name="John Doe" --email=john@example.com

#安装S3cmd客户端
yum install s3cmd -y

#创建Bucket时出现错误:
s3cmd mb s3://test-bucket
ERROR: S3 error: 403 (RequestTimeTooSkewed)
## 先确定时区和时间是否同步

```


#### 添加新机器到集群

##### 扩展MON
- 随便找一台正在运行的mon节点上修改ceph.conf，增加相应的mon initial members与mon host，不再赘述。然后同步到所有节点。
- 获取集群已有的mon.keyring
``` shell
ceph auth get mon. -o mon.keyring

```
- 获取集群已有的mon.map
```shell
ceph mon getmap -o mon.map

```
- 创建监视数据目录
```shell
#确定以下默认目录已经存在
#/var/lib/ceph/mon/{cluster-name}-{mon-id}/
#例如：/var/lib/ceph/mon/ceph-asianux76-a/

ceph-mon -i ceph1 --mkfs --monmap mon.map --keyring mon.keyring

#以上ceph1为mon id
```
- 启动mon节点
```shell
ceph-mon -i `hostname -s` --public-addr 192.168.3.136:6789

#注意ip为新节点ip  `hostname -s` 是mon的ID,可以任意
```

##### 扩展OSD

###### 添加方式一：添加后osd立刻生效，会触发数据均衡
```shell
#1.登陆原集群任意osd节点
scp /var/lib/ceph/bootstrap-osd/keyring newnode:$PWD
scp /etc/ceph/ceph.client.admin.keyring /etc/ceph/ceph.conf newnode:$PWD

ceph-volume lvm create --data /dev/sdb(此处替换成新节点设备名)

```
###### 以下暂未成功
```shell
#登陆新节点创建OSD
ceph osd create
#生成id 为 3

#创建osd数据目录
mkdir /var/lib/ceph/osd/ceph-3
chown -R ceph:ceph /var/lib/ceph/osd/ceph-3

#执行命令
ceph-authtool /tmp/osd.keyring --gen-key -n osd.3

ceph auth add osd.3 osd 'allow *' mon 'allow profile osd' -i /var/lib/ceph/osd/ceph-3/keyring


```