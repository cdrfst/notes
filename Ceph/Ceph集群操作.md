| 服务名称               | 功能描述                | 最低配置                   |
| ------------------ | ------------------- | ---------------------- |
| Ceph OSD           | 存储数据和元数据            | 4核CPU、16GB内存、50GB磁盘空间  |
| Ceph MON           | 监控整个集群的状态和性能        | 2核CPU、4GB内存            |
| Ceph MDS           | 提供文件系统和元数据服务        | 2核CPU、8GB内存、50GB磁盘空间   |
| Ceph RGW           | 基于REST接口提供对象存储服务    | 2核CPU、4GB内存            |
| Ceph RADOS Gateway | 提供S3和Swift接口的对象存储服务 | 2核CPU、4GB内存            |
| Ceph Manager       | 提供管理整个集群的工具和接口      | 2核CPU、8GB内存            |
| Ceph Dashboard     | 提供Web UI管理工具        | 2核CPU、4GB内存            |
| Ceph NFS           | 提供NFS接口的文件存储服务      | 4核CPU、16GB内存、100GB磁盘空间 |
| Ceph iSCSI         | 提供iSCSI接口的块存储服务     | 4核CPU、16GB内存、100GB磁盘空间 |

## 剔除OSD

1. 进入维护模式
```shell
ceph osd set noout
ceph osd set nobackfill
ceph osd set norecover
ceph osd set norebalance
```
2. 查看osd信息
```shell
#首先收集osd信息
[root@server3 ~]# ceph osd tree
ID CLASS WEIGHT  TYPE NAME        STATUS REWEIGHT PRI-AFF 
-1       0.14575 root default                             
-3       0.04858     host server1                         
 1   hdd 0.02429         osd.1        up  1.00000 1.00000 
 2   hdd 0.02429         osd.2        up  1.00000 1.00000 
-7       0.04858     host server2                         
 4   hdd 0.02429         osd.4        up  1.00000 1.00000 
 5   hdd 0.02429         osd.5        up  1.00000 1.00000 
-5       0.04858     host server3                         
 0   hdd 0.02429         osd.0        up  1.00000 1.00000 
 3   hdd 0.02429         osd.3        up  1.00000 1.00000 
​
​
#查看osd挂载
​
ot@server3 ~]# df -TH
Filesystem              Type      Size  Used Avail Use% Mounted on
/dev/mapper/centos-root xfs        19G  1.5G   17G   9% /
devtmpfs                devtmpfs  969M     0  969M   0% /dev
tmpfs                   tmpfs     982M     0  982M   0% /dev/shm
tmpfs                   tmpfs     982M   11M  972M   2% /run
tmpfs                   tmpfs     982M     0  982M   0% /sys/fs/cgroup
/dev/sda1               xfs       1.1G  149M  915M  14% /boot
tmpfs                   tmpfs     197M     0  197M   0% /run/user/0
/dev/sdb1               xfs       102M  5.6M   96M   6% /var/lib/ceph/osd/ceph-0
/dev/sdc1               xfs       102M  5.6M   96M   6% /var/lib/ceph/osd/ceph-3
```
3. 剔除操作
```shell
systemctl stop ceph-osd@3
ceph osd out 3
ceph osd crush remove osd.3
ceph auth del osd.3
ceph osd rm osd.3
umount /var/lib/ceph/osd/ceph-3
```
4. 解除维护状态
```shell
ceph osd unset noout
ceph osd unset nobackfill
ceph osd unset norecover
ceph osd unset norebalance
```

*命令含义*
1：将osd down掉
ceph osd down osd.0
    （这样停止的话，osd会被集群自动启动起来，所以保险起见还是在osd所在服务器将osd所属服务给停掉 systemctl stop ceph-osd@0）

2：将osd从集群中退出
ceph osd out osd.0

3：从crush中移除节点
ceph osd crush remove osd.0

4：删除节点
ceph osd rm osd.0

5：删除OSD节点认证（不删除编号会占住）
ceph auth del osd.0

## 剔除MON节点

查看mon列表

- 停止<将要剔除的>mon服务
- ceph mon remove <mon id>
- 
- 从ceph.conf中删除<将要剔除的>mon配置

## 剔除radosgw

1. 停服务
```shell
sudo systemctl stop ceph-radosgw@rgw.bigdata7
```
2. 剔除
```shell
ceph auth del client.rgw.bigdata7
```

## Ceph.conf

```shell
[global]
fsid = {cluster-id}
mon initial members = {hostname}[, {hostname}]
mon host = {ip-address}[, {ip-address}]

#All clusters have a front-side public network.
#If you have two NICs, you can configure a back side cluster 
#network for OSD object replication, heart beats, backfilling,
#recovery, etc.
public network = {network}[, {network}]
#cluster network = {network}[, {network}] 

#Clusters require authentication by default.
auth cluster required = cephx
auth service required = cephx
auth client required = cephx

#Choose reasonable numbers for your journals, number of replicas
#and placement groups.
osd journal size = {n}
osd pool default size = {n}  # Write an object n times.
osd pool default min size = {n} # Allow writing n copy in a degraded state.
osd pool default pg num = {n}
osd pool default pgp num = {n}

#Choose a reasonable crush leaf type.
#0 for a 1-node cluster.
#1 for a multi node cluster in a single rack
#2 for a multi node, multi chassis cluster with multiple hosts in a chassis
#3 for a multi node cluster with hosts across racks, etc.
osd crush chooseleaf type = {n}
```

在Ceph中，CRUSH（Controlled Replication Under Scalable Hashing）算法用于数据分布和故障域划分。在配置文件中，osd crush chooseleaf type选项用于指定CRUSH算法中的叶子节点类型。下面是对不同leaf type选项的解释：

- 0：适用于只有一个节点的集群。此时，整个集群只有一个叶子节点，数据将存储在该节点上。
- 1：适用于单个机架内的多节点集群。此时，机架是叶子节点，数据将在机架内的多个节点上进行分布。
- 2：适用于多机架、多机箱的集群，每个机箱内有多个主机。此时，机箱是叶子节点，数据将在机箱内的多个主机上进行分布。
- 3：适用于跨机架的多节点集群。此时，每个节点都是叶子节点，数据将在不同机架上的多个节点之间进行分布。

根据您的集群架构，选择适合的leaf type选项可以帮助实现数据的均衡分布和故障域的划分。在实际配置中，您可以根据集群的物理结构和需求选择合适的leaf type值，并根据需要进行调整。