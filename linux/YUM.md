## YUM源的种类

|源名称|说明|
|------|------|
|base	|操作系统镜像源，包含了ISO镜像内的所有软件包
|updates|	包含了系统更新，升级的软件包
|extras	|扩充的软件包合集
|epel	|EPEL (Extra Packages for Enterprise Linux)是基于Fedora的一个项目，为“红帽系”的操作系统提供额外的软件包，适用于RHEL、CentOS和Scientific Linux.

## Redhat 7.4 配置YUM源
### 1.查看自带的yum
``` shell
[ecm@ecm-13 yum.repos.d]$ rpm -aq|grep yum
yum-metadata-parser-1.1.4-10.el7.x86_64
yum-3.4.3-168.el7.centos.noarch
yum-plugin-fastestmirror-1.1.31-54.el7_8.noarch

```
### 2.卸载自带yum
``` shell
[root@ecm-13 yum.repos.d]# rpm -qa |grep yum | xargs rpm -e --nodeps
warning: /etc/yum.conf saved as /etc/yum.conf.rpmsave
[root@ecm-13 yum.repos.d]# rpm -qa|grep yum
[root@ecm-13 yum.repos.d]#

```

### 3.使用Centos7的yum包

	下载地址: https://mirrors.aliyun.com/centos/7/os/x86_64/Packages/
将所需要包都放到同一目录下：

``` shell
python-urlgrabber-3.10-10.el7.noarch.rpm
wget-1.14-18.el7_6.1.x86_64.rpm
yum-3.4.3-168.el7.centos.noarch.rpm
yum-metadata-parser-1.1.4-10.el7.x86_64.rpm
yum-plugin-fastestmirror-1.1.31-54.el7_8.noarch.rpm
yum-utils-1.1.31-54.el7_8.noarch.rpm

```

执行安装命令

``` shell
rpm -ivh python-urlgrabber-3.10-10.el7.noarch.rpm --replacefiles
rpm -ivh yum-metadata-parser-1.1.4-10.el7.x86_64.rpm yum-3.4.3-168.el7.centos.noarch.rpm yum-plugin-fastestmirror-1.1.31-54.el7_8.noarch.rpm wget-1.14-18.el7_6.1.x86_64.rpm
```

下载阿里镜像配置
``` shell
# 配置centos的base源和epel源为阿里源  
 wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo  
 wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo  
 yum clean all  
 yum makecache fast
修改刚下载的文件使用查找替换方式，(:%s/$releasever/7/g)，将所有$releasever替换为7
```

yum clean all
yum makecache

``` shell
[root@ecm-13 yum.repos.d]# yum makecache
Loaded plugins: fastestmirror, product-id, search-disabled-repos
Loading mirror speeds from cached hostfile
 * base: mirrors.aliyun.com
 * centos-sclo-rh: mirrors.huaweicloud.com
 * centos-sclo-sclo: mirrors.huaweicloud.com
 * extras: mirrors.aliyun.com
 * updates: mirrors.aliyun.com
http://mirrors.cloud.aliyuncs.com/centos/7/os/x86_64/repodata/repomd.xml: [Errno 14] curl#6 - "Could not resolve host: mirrors.cloud.aliyuncs.com; Unknown error"
```

### 遇到的问题及解决办法

> "Could not resolve host: mirrors.cloud.aliyuncs.com; Unknown error"
>>
>>vi /etc/resolv.conf
>>#添加以下dns
>> nameserver 8.8.8.8
>> nameserver 114.114.114.114

## 仅下载不安装



### 1.安装 yum-downloadonly 插件
``` shell
yum install yum-downloadonly
```
### 2.使用方法
``` shell
yum install salt --downloadonly --downloaddir=/tmp
```

## 常用命令

```shell
#查看可用的ceph 版本
yum list ceph --showduplicates

```