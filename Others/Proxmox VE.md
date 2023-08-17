
## 去除Proxmox企业源
vi /etc/apt/sources.list.d/pve-enterprise.list
``` shell
#deb https://enterprise.proxmox.com/debian/pve buster pve-enterprise
```

# 修改更新源


``` shell
wget https://mirrors.ustc.edu.cn/proxmox/debian/proxmox-release-bullseye.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg
echo "deb https://mirrors.ustc.edu.cn/proxmox/debian/pve bullseye pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list     #中科大源
echo "deb https://mirrors.ustc.edu.cn/proxmox/debian/ceph-pacific bullseye main" > /etc/apt/sources.list.d/ceph.list     #中科大源
sed -i.bak "s#http://download.proxmox.com/debian#https://mirrors.ustc.edu.cn/proxmox/debian#g" /usr/share/perl5/PVE/CLI/pveceph.pm     #中科大源
sed -i.bak "s#ftp.debian.org/debian#mirrors.aliyun.com/debian#g" /etc/apt/sources.list     #阿里Debian源
sed -i "s#security.debian.org#mirrors.aliyun.com/debian-security#g" /etc/apt/sources.list     #阿里Debian源
apt update && apt dist-upgrade
```


# 加速CT Templates

如果你需要加速 Proxmox 网页端下载 CT Templates，可以替换 CT Templates 的源为 [https://mirrors.tuna.tsinghua.edu.cn](https://mirrors.tuna.tsinghua.edu.cn/)。  
具体方法：将 `/usr/share/perl5/PVE/APLInfo.pm` 文件中默认的源地址 `http://download.proxmox.com` 替换为 `https://mirrors.tuna.tsinghua.edu.cn/proxmox` 即可。  
可以使用如下命令修改：
```shell
cp /usr/share/perl5/PVE/APLInfo.pm /usr/share/perl5/PVE/APLInfo.pm_back
sed -i 's|http://download.proxmox.com|https://mirrors.tuna.tsinghua.edu.cn/proxmox|g' /usr/share/perl5/PVE/APLInfo.pm
```

针对 `/usr/share/perl5/PVE/APLInfo.pm` 文件的修改，重启后生效。

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

