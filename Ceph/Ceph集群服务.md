| 服务名称 | 功能描述 | 最低配置 |
| --------- | -------- | -------- |
| Ceph OSD | 存储数据和元数据 | 4核CPU、16GB内存、50GB磁盘空间 |
| Ceph MON | 监控整个集群的状态和性能 | 2核CPU、4GB内存 |
| Ceph MDS | 提供文件系统和元数据服务 | 2核CPU、8GB内存、50GB磁盘空间 |
| Ceph RGW | 基于REST接口提供对象存储服务 | 2核CPU、4GB内存 |
| Ceph RADOS Gateway | 提供S3和Swift接口的对象存储服务 | 2核CPU、4GB内存 |
| Ceph Manager | 提供管理整个集群的工具和接口 | 2核CPU、8GB内存 |
| Ceph Dashboard | 提供Web UI管理工具 | 2核CPU、4GB内存 |
| Ceph NFS | 提供NFS接口的文件存储服务 | 4核CPU、16GB内存、100GB磁盘空间 |
| Ceph iSCSI | 提供iSCSI接口的块存储服务 | 4核CPU、16GB内存、100GB磁盘空间 |

## 删除OSD

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

6：删除crush map中对应OSD条目
ceph crush remove osd.0

