# 修改更新源

## **Debian系统源（阿里云源）和proxmox源**
vi /etc/apt/sources.list

``` shell
#deb http://ftp.debian.org/debian buster main contrib
#deb http://ftp.debian.org/debian buster-updates main contrib
# security updates
#deb http://security.debian.org buster/updates main contrib

# debian aliyun source
deb https://mirrors.aliyun.com/debian buster main contrib non-free
deb https://mirrors.aliyun.com/debian buster-updates main contrib non-free
deb https://mirrors.aliyun.com/debian-security buster/updates main contrib non-free

# proxmox source
# deb http://download.proxmox.com/debian/pve buster pve-no-subscription
deb https://mirrors.ustc.edu.cn/proxmox/debian/pve buster pve-no-subscription
```

## **去除Proxmox企业源**
vi /etc/apt/sources.list.d/pve-enterprise.list
``` shell
#deb https://enterprise.proxmox.com/debian/pve buster pve-enterprise
```


# 安装Docker
参考: https://docs.docker.com/engine/install/debian/
