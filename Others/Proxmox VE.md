# 修改更新源

## Debian系统源（阿里云源）和proxmox源
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

## 去除Proxmox企业源
vi /etc/apt/sources.list.d/pve-enterprise.list
``` shell
#deb https://enterprise.proxmox.com/debian/pve buster pve-enterprise
```


# 安装Docker
参考: https://docs.docker.com/engine/install/debian/

# 删除local-lvm

lvremove pve/data     # 移除local-lvm
vgdisplay pve | grep Free
lvextend -l +100%FREE -f pve/root     # 将卷组中的空闲空间扩展到根目录
fdisk -l
resize2fs /dev/mapper/pve-root     # 刷新扩容根分区

2.在页面 数据中心->存储 ：删除local-lvm 后 编辑local 将内容全选


lsblk  树形显示磁盘和分区
# Summary->IPs显示
1. 需要在具体虚拟机->Options 中启用Qemu Agent 为 Enable 
2. 进入虚拟机系统中安装 qemu-guest-agent
	1. windows 在virtio-win-0.1.225.iso 中的 guest-agent文件夹中
	2. linux 虚机机可执行安装命令  ``apt-get install qemu-guest-agent

# 有时虚拟节点网络无法连接
常见于 windows 节点无法远程访问
[引用](https://www.cnblogs.com/nf01/p/16296724.html)

问题错误日志：
vi /var/log/syslog
异常信息：``e1000e 0000:00:1f.6 eno1: Detected Hardware Unit Hang

```shell
#如果没有ethtool工具可以执行如下命令安装： 
apt install ethtool 
#禁用 tcp 分段卸载和通用分段卸载
ethtool -K eno1 tso off gso off

#2023/2/6 9:54 执行完的命令，观察中。。。
```

# 手动删除Snapshot

```shell
# qm unlock VMID
qm unlock 100
# qm delsnapshot VMID snapshotname --force
qm delsnapshot 100 testsnapshot --force
```
