## flume真实日志采集流程

### 一、日志->Flume->HDFS

将本系统中的两种日志(start、event)分别按日志生成日期导入到hdfs目录(user/data/logs/start、user/data/logs/event)下

flume agent 脚本 flume-log2hdfs3.conf:

```shell
a1.sources = r1 
a1.sinks = k1 
a1.channels = c1 
# taildir source 
a1.sources.r1.type = TAILDIR 
a1.sources.r1.positionFile = /data/lagoudw/conf/startlog_position.json 
a1.sources.r1.filegroups = f1 f2 
a1.sources.r1.filegroups.f1 = /data/lagoudw/logs/start/.*log 
a1.sources.r1.headers.f1.logtype = start 
a1.sources.r1.filegroups.f2 = /data/lagoudw/logs/event/.*log 
a1.sources.r1.headers.f2.logtype = event 
# 自定义拦截器 
a1.sources.r1.interceptors = i1 
a1.sources.r1.interceptors.i1.type = cn.lagou.dw.flume.interceptor.LogTypeInterceptor$Builder 
# memorychannel 
a1.channels.c1.type = memory 
a1.channels.c1.capacity = 100000 
a1.channels.c1.transactionCapacity = 2000 
# hdfs sink 
a1.sinks.k1.type = hdfs 
a1.sinks.k1.hdfs.path = /user/data/logs/%{logtype}/dt=%{logtime}/ 
a1.sinks.k1.hdfs.filePrefix = startlog
a1.sinks.k1.hdfs.fileType = DataStream
# 配置文件滚动方式（文件大小32M） 
a1.sinks.k1.hdfs.rollSize = 33554432 
a1.sinks.k1.hdfs.rollCount = 0 
a1.sinks.k1.hdfs.rollInterval = 0 
a1.sinks.k1.hdfs.idleTimeout = 0 
a1.sinks.k1.hdfs.minBlockReplicas = 1 
# 向hdfs上刷新的event的个数 
a1.sinks.k1.hdfs.batchSize = 1000 
# Bind the source and sink to the channel 
a1.sources.r1.channels = c1 
a1.sinks.k1.channel = c1
```

执行flume ng 前先清理历史数据(<!--非必要且需谨慎-->):

```shell
rm -f /data/lagoudw/logs/start/*.log
rm -f /data/lagoudw/logs/event/*.log
rm -f /data/lagoudw/conf/startlog_position.json

hdfs dfs -rm -r -f /user/data/logs/start/*
hdfs dfs -rm -r -f /user/data/logs/event/*
```

执行flume(测试):

```shell
flume-ng agent --conf /opt/lagou/servers/flume-1.9.0/conf --conf-file /data/lagoudw/conf/flume-log2hdfs3.conf -name a1 -Dflume.root.logger=INFO,console
```

执行flume(正式)

```shell
nohup flume-ng agent --conf /opt/lagou/servers/flume-1.9.0/conf --conf-file /data/lagoudw/conf/flume-log2hdfs3.conf -name a1 -Dflume.root.logger=INFO,LOGFILE > /dev/null 2>&1 &
```

复制日志文件进行测试:

```
cp /root/start0721.small.log /data/lagoudw/logs/start/
cp /root/start0722.small.log /data/lagoudw/logs/start/
cp /root/start0723.small.log /data/lagoudw/logs/start/

cp /root/eventlog0721.small.log /data/lagoudw/logs/event/
```

[跳转到Flume]()

### 二、HDFS->Hive

本项目划分为四个层(分别对应四个库):

ODS	DWD	DWS	ADS

#### ODS层:

简介：本层整体数据结构与hdfs中数据文件一致,主要过滤了格式不规范数据

将日志数据通过脚本导入ods.ods_start_log 表

```sql
use ODS; 
create external table ods.ods_start_log( `str` string) 
comment '用户启动日志信息' 
partitioned by (`dt` string) 
location '/user/data/logs/start';
```

-- 加载数据到数据表(测试时使用) 

```sql
alter table ods.ods_start_log add partition(dt='2020-07-20'); 
alter table ods.ods_start_log drop partition (dt='2020-07-20');
```

将上面的脚本自动化,主要解决手动调用还要传日期参数的问题,新建脚本文件 ods_start_log.sh

```bash
#！/bin/bash 
APP=ODS 
hive=/opt/lagou/servers/hive-2.3.7/bin/hive 
# 可以输入日期；如果未输入日期取昨天的时间 
if [ -n "$1" ] 
then
	do_date=$1 
else
    do_date=`date -d "-1 day" +%F` 
fi
# 定义要执行的SQL 
sql="alter table "$APP".ods_start_log add partition(dt='$do_date');"
$hive -e "$sql"

```

调用时可以直接 ods_start_log.sh 2020-07-20  也可以不带日期参数 默认是昨天日期

#### DWD层:

将ods层的json数据 解析成明细字段

```sql
use DWD; 
drop table if exists dwd.dwd_start_log; 
CREATE TABLE dwd.dwd_start_log( 
    `device_id` string, 
    `area` string, 
    `uid` string, 
    `app_v` string, 
    `event_type` string, 
    `os_type` string, 
    `channel` string, 
    `language` string, 
    `brand` string, 
    `entry` string, 
    `action` string, 
    `error_code` string )
PARTITIONED BY (dt string) STORED AS parquet;
```



dwd_load_start.sh

```bash
#！/bin/bash 
source /etc/profile 
# 可以输入日期；如果未输入日期取昨天的时间 
if [ -n "$1" ] 
	then
		do_date=$1 
	else
		do_date=`date -d "-1 day" +%F` 
fi
# 定义要执行的SQL
sql=" 
    with tmp as( select split(str, ' ')[7] line from ods.ods_start_log where dt='$do_date' )
    insert overwrite table dwd.dwd_start_log partition(dt='$do_date') 
    select 
    get_json_object(line, '$.attr.device_id'), 
    get_json_object(line, '$.attr.area'), 
    get_json_object(line, '$.attr.uid'), 
    get_json_object(line, '$.attr.app_v'), 
    get_json_object(line, '$.attr.event_type'), 
    get_json_object(line, '$.attr.os_type'), 
    get_json_object(line, '$.attr.channel'), 
    get_json_object(line, '$.attr.language'), 
    get_json_object(line, '$.attr.brand'), 
    get_json_object(line, '$.app_active.json.entry'), 
    get_json_object(line, '$.app_active.json.action'), 
    get_json_object(line, '$.app_active.json.error_code') 
    from tmp;"
    
    hive -e "$sql"
```

#### DWS层:

对dwd层的轻度汇总

建dws层表:

```sql
use dws; 
drop table if exists dws.dws_member_start_day; 
create table dws.dws_member_start_day 
(`device_id` string, 
 `uid` string, 
 `app_v` string, 
 `os_type` string, 
 `language` string, 
 `channel` string, 
 `area` string, 
 `brand` string ) 
 COMMENT '会员日启动汇总' 
 partitioned by(dt string) stored as parquet;
 
 drop table if exists dws.dws_member_start_week; 
 create table dws.dws_member_start_week( 
     `device_id` string, 
     `uid` string, 
     `app_v` string, 
     `os_type` string, 
     `language` string, 
     `channel` string, 
     `area` string, 
     `brand` string, 
     `week` string ) 
     COMMENT '会员周启动汇总' 
     PARTITIONED BY (`dt` string) stored as parquet;
     
 drop table if exists dws.dws_member_start_month;
create table dws.dws_member_start_month( 
    `device_id` string, 
    `uid` string, 
    `app_v` string, 
    `os_type` string, 
    `language` string, 
    `channel` string, 
    `area` string, 
    `brand` string, 
    `month` string ) 
    COMMENT '会员月启动汇总' 
    PARTITIONED BY (`dt` string) stored as parquet;
```

加载dws层数据:

```shell
#！/bin/bash 
source /etc/profile 
# 可以输入日期；如果未输入日期取昨天的时间 
if [ -n "$1" ] 
	then
		do_date=$1 
	else
		do_date=`date -d "-1 day" +%F` 
fi
# 定义要执行的SQL 
# 汇总得到每日活跃会员信息；每日数据汇总得到每周、每月数据 
sql=" 
insert overwrite table dws.dws_member_start_day partition(dt='$do_date') 
select device_id, 
concat_ws('|', collect_set(uid)), 
concat_ws('|', collect_set(app_v)), 
concat_ws('|', collect_set(os_type)), 
concat_ws('|', collect_set(language)), 
concat_ws('|', collect_set(channel)), 
concat_ws('|', collect_set(area)), 
concat_ws('|', collect_set(brand)) 
from dwd.dwd_start_log 
where dt='$do_date' 
group by device_id; 

-- 汇总得到每周活跃会员 
insert overwrite table dws.dws_member_start_week partition(dt='$do_date') 
select device_id,
concat_ws('|', collect_set(uid)), 
concat_ws('|', collect_set(app_v)), 
concat_ws('|', collect_set(os_type)), 
concat_ws('|', collect_set(language)), 
concat_ws('|', collect_set(channel)), 
concat_ws('|', collect_set(area)), 
concat_ws('|', collect_set(brand)), 
date_add(next_day('$do_date', 'mo'), -7) 
from dws.dws_member_start_day 
where dt >= date_add(next_day('$do_date', 'mo'), -7) and dt <= '$do_date' 
group by device_id; 

-- 汇总得到每月活跃会员 
insert overwrite table dws.dws_member_start_month partition(dt='$do_date') 
select device_id, 
concat_ws('|', collect_set(uid)), 
concat_ws('|', collect_set(app_v)), 
concat_ws('|', collect_set(os_type)), 
concat_ws('|', collect_set(language)), 
concat_ws('|', collect_set(channel)), 
concat_ws('|', collect_set(area)), 
concat_ws('|', collect_set(brand)), 
date_format('$do_date', 'yyyy-MM') 
from dws.dws_member_start_day 
where dt >= date_format('$do_date', 'yyyy-MM-01') and dt <= '$do_date' 
group by device_id; "

hive -e "$sql"
```



ADS层:

计算当天、当周、当月活跃会员数量

```sql
drop table if exists ads.ads_member_active_count; 
create table ads.ads_member_active_count( 
`day_count` int COMMENT '当日会员数量', 
`week_count` int COMMENT '当周会员数量', 
`month_count` int COMMENT '当月会员数量',
`seven_days_count` int COMMENT '近七天活跃会员数量')
COMMENT '活跃会员数' partitioned by(dt string) row format delimited fields terminated by ',';
```

加载 ADS 层数据

ads_load_member_active.sh

```shell
#!/bin/bash 
source /etc/profile 
if [ -n "$1" ] 
then 
do_date=$1 
else 
do_date=`date -d "-1 day" +%F` 
fi
sql=" 
with tmp as( 
select 'day' datelabel, count(*) cnt, dt from dws.dws_member_start_day where dt='$do_date' group by dt 
union all 
select 'week' datelabel, count(*) cnt, dt from dws.dws_member_start_week where dt='$do_date' group by dt 
union all 
select 'month' datelabel, count(*) cnt, dt from dws.dws_member_start_month where dt='$do_date' group by dt
union all 
select 'seven_days_count' datelabel, count(device_id) cnt, '$do_date' dt from (
 select device_id,count(gid) as lxnum from(
  select device_id,dt,date_sub(dt,rn) as gid from (
   select device_id,dt,row_number() over(partition by device_id order by dt) as rn
   from dws.dws_member_start_day where dt>=date_sub('$do_date',7))tmp
  )tmp2
 group by device_id having count(gid)>=3)tmp3
 )

insert overwrite table ads.ads_member_active_count partition(dt='$do_date') 
select 
sum(case when datelabel='day' then cnt end) as day_count, 
sum(case when datelabel='week' then cnt end) as week_count, 
sum(case when datelabel='month' then cnt end) as month_count,
sum(case when datelabel='seven_days_count' then cnt end) as seven_days_count
from tmp group by dt; "

hive -e "$sql"
```

