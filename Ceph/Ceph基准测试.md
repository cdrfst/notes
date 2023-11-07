## 带宽测试
### 工具iperf3
[引用](https://zhuanlan.zhihu.com/p/314727150)
模拟Server 端，每1秒采集一次带宽信息，监听1314端口
```shell
iperf3 -s -i 1 -p 1314
```
模拟Client端，连接服务器1314端口
```shell
iperf3 -c 10.10.0.2 -i 1 -t 60 -p 1314
```

## 磁盘测试
### 工具FIO
[项目地址](https://github.com/axboe/fio)
[引用](https://juejin.cn/post/7090839375033925646)

用iostat查看硬盘情况

iostat是一个用于监视系统磁盘I/O活动的实用程序。它可以提供有关硬盘性能、使用情况和吞吐量的详细信息。以下是使用iostat查看硬盘情况的步骤：

打开终端或命令行界面。

运行以下命令来安装sysstat软件包（如果尚未安装）：

sudo apt install sysstat  # 对于基于Debian的发行版（如Ubuntu）
sudo yum install sysstat  # 对于基于RHEL/CentOS的发行版
运行以下命令来查看磁盘的实时I/O统计数据：

iostat -d
这将显示每个磁盘设备的详细信息，包括读取和写入速率、I/O请求队列长度、等待时间和响应时间等。

如果你只想显示特定磁盘设备的信息，可以使用以下命令：

iostat -d <设备名称>
将<设备名称>替换为你要监视的磁盘设备的名称，例如/dev/sda。

此外，iostat还提供了其他选项和参数，可以通过man iostat命令查看iostat的手册页获取更多详细信息。


## 基准测试
### 工具Cosbench
[旧版项目地址](https://github.com/intel-cloud/cosbench/releases/tag/v0.4.2)
[引用](https://blog.csdn.net/wuxiaobingandbob/article/details/80883529)
[新版项目地址](https://github.com/sine-io/cosbench-sineio)
[引用](https://blog.csdn.net/qq_33704587/article/details/127120141)


https://cloud.tencent.com/document/practice/436/47974

http://192.168.3.161:19088/controller/


## 参数优化


PGs = (Total_number_of_OSD * 100) / max_replication_count
如果有15个OSD，副本数为3，根据公式计算PGs为500，最接近512，所以需要设置该pool的pg_num和pgp_num都为512

ceph osd pool set {pool name} pg_num 512
ceph osd pool set {pool name} pgp_num 512


The following settings only apply on cluster creation and are then stored in the OSDMap.

[global]

        mon osd full ratio = .80
        mon osd backfillfull ratio = .75
        mon osd nearfull ratio = .70
mon osd full ratio

Description
The percentage of disk space used before an OSD is considered full.

Type
Float

Default
0.95

mon osd backfillfull ratio

Description
The percentage of disk space used before an OSD is considered too full to backfill.

Type
Float

Default
0.90

mon osd nearfull ratio

Description
The percentage of disk space used before an OSD is considered nearfull.

Type
Float

Default
0.85

Tip If some OSDs are nearfull, but others have plenty of capacity, you may have a problem with the CRUSH weight for the nearfull OSDs.
Tip These settings only apply during cluster creation. Afterwards they need to be changed in the OSDMap using ceph osd set-nearfull-ratio and ceph osd set-full-ratio