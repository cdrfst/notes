
## 必备条件
### 1. python3

https://blog.csdn.net/QIU176161650/article/details/118784155

## 搭建方式
### 1. 官方推荐
#### cephadm 安装方式
	仅支持对 Octopus 和更新的版本安装
	cephadm完全集成了新的业务流程API，并完全支持新的CLI和仪表板功能来管理集群部署
	cephadm requires container support (podman or docker) and Python 3

#### 


## 关闭防火墙

``` shell
systemctl stop firewalld | systemctl disable firewalld | systemctl status firewalld
```
## 内网时间同步

https://www.cnblogs.com/xiongty/p/14886447.html

## 新建用户
## 加入sudoers
## 配置互信

## Centos7 or RH7

https://www.cnblogs.com/weiwei2021/p/14060186.html

``` shell
#离线下载ceph-deploy
sudo yum -y install --downloadonly --downloaddir=/home/tiaf/cephcentos7/ceph-deploy/ ceph-deploy python-pip

#离线下载ceph (离线安装下面包时还会自动下载一些依赖,如环境不同需要每台单独执行)
sudo yum -y install --downloadonly --downloaddir=/home/tiaf/cephcentos7/ceph/ ceph  ceph-radosgw

# 本地安装
sudo yum localinstall *.rpm
```

### ceph-deploy部署
``` shell
ceph-deploy new 节点1 节点2
# ceph-deploy –cluster {cluster-name} new node1 node2 //创建一个自定集群名称的ceph集群，默
认为 ceph
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


## 统信uos

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
