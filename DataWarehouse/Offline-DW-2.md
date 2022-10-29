
### part1

​	**用拉链表实现核心交易分析中DIM层商家维表，并实现该拉链表的回滚**

#### 加载ods层数据

ods_load_trade.sh

```
#!/bin/bash
source /etc/profile
if [ -n "$1" ]
 then do_date=$1
else
 do_date=`date -d "-1 day" +%F`
fi
# 创建目录
hdfs dfs -mkdir -p /user/data/trade.db/product_category/dt=$do_date
hdfs dfs -mkdir -p /user/data/trade.db/shops/dt=$do_date
hdfs dfs -mkdir -p /user/data/trade.db/shop_org/dt=$do_date
hdfs dfs -mkdir -p /user/data/trade.db/payments/dt=$do_date
hdfs dfs -mkdir -p /user/data/trade.db/orders/dt=$do_date
hdfs dfs -mkdir -p /user/data/trade.db/order_product/dt=$do_date
hdfs dfs -mkdir -p /user/data/trade.db/product_info/dt=$do_date
# 数据迁移
python $DATAX_HOME/bin/datax.py -p "-Ddo_date=$do_date" /data/lagoudw/json/product_category.json
python $DATAX_HOME/bin/datax.py -p "-Ddo_date=$do_date" /data/lagoudw/json/shops.json
python $DATAX_HOME/bin/datax.py -p "-Ddo_date=$do_date" /data/lagoudw/json/shop_org.json
python $DATAX_HOME/bin/datax.py -p "-Ddo_date=$do_date" /data/lagoudw/json/payments.json
python $DATAX_HOME/bin/datax.py -p "-Ddo_date=$do_date" /data/lagoudw/json/orders.json
python $DATAX_HOME/bin/datax.py -p "-Ddo_date=$do_date" /data/lagoudw/json/order_product.json
python $DATAX_HOME/bin/datax.py -p "-Ddo_date=$do_date" /data/lagoudw/json/product_info.json
# 加载 ODS 层数据
sql="
alter table ods.ods_trade_orders add partition(dt='$do_date');
alter table ods.ods_trade_order_product add partition(dt='$do_date');
alter table ods.ods_trade_product_info add partition(dt='$do_date');
alter table ods.ods_trade_product_category add partition(dt='$do_date');
alter table ods.ods_trade_shops add partition(dt='$do_date');
alter table ods.ods_trade_shop_admin_org add partition(dt='$do_date');
alter table ods.ods_trade_payments add partition(dt='$do_date'); "
hive -e "$sql"
```

加载 2020-07-12号数据

```
sh ods_load_trade.sh 2020-07-12
```

#### 加载DIM层数据

dim_load_shop_org.sh

```
#！/bin/bash
source /etc/profile
if [ -n "$1" ]
then
do_date=$1
else
do_date=`date -d "-1 day" +%F`
fi
sql="
insert overwrite table dim.dim_trade_shops_org partition(dt='$do_date')
select t1.shopid, t1.shopname, t2.id as cityid, t2.orgname as cityName, t3.id as region_id, t3.orgname as region_name
from (select shopId, shopName, areaId from ods.ods_trade_shops where dt='$do_date') t1
left join
(select id, parentId, orgname, orglevel from ods.ods_trade_shop_admin_org where orglevel=2 and dt='$do_date') t2 on t1.areaid = t2.id
left join (select id, parentId, orgname, orglevel from ods.ods_trade_shop_admin_org where orglevel=1 and dt='$do_date') t3 on t2.parentid = t3.id; "
hive -e "$sql"

```

```
sh dim_load_shop_org.sh 2020-07-12
```

#### 初始化拉链表

```
CREATE TABLE `test.shops_org_zipper`(
  `shopid` int,
  `shopname` string,
  `cityid` int,
  `cityname` string,
  `regionid` int,
  `regionname` string,
  `start_date` string,
  `end_date` string)
```

shopszipper.sh

```
#!/bin/bash
source /etc/profile
if [ -n "$1" ]
then do_date=$1
else
do_date=`date -d "-1 day" +%F`
fi
sql="
insert overwrite table test.shops_org_zipper
select shopid, shopname, cityid, cityName, regionid, regionname, dt as start_date, '9999-12-31' as end_date
from dim.dim_trade_shops_org
where dt='$do_date'
union all
select B.shopid, B.shopname, B.cityid, B.cityName, B.regionid, B.regionname, B.start_Date,
case when B.end_date='9999-12-31' and A.shopid is not null then date_add('$do_date', -1) else B.end_date end as end_date
from (select * from dim.dim_trade_shops_org where dt='$do_date') A
right join test.shops_org_zipper B on A.shopid=B.shopid; "
hive -e "$sql"
```

```
sh shopszipper.sh 2020-07-12
```

拉链表

![image-20210818094530532](images\image-20210818094530532.png)

#### 导入增量数据

自定义增量数据

![image-20210817175343743](images\image-20210817175343743.png)

重复上述数据导入步骤导入 2020-07-13 增量数据

```
sh ods_load_trade.sh 2020-07-13
sh dim_load_shop_org.sh 2020-07-13
sh shopszipper.sh 2020-07-13
```



##### 拉链表(回滚前)

![image-20210818094847489](images\image-20210818094847489.png)

#### 拉链表回滚

rollbackshopszipper.sh

```
#!/bin/bash
source /etc/profile
if [ -n "$1" ]
then do_date=$1
else
do_date=`date -d "-1 day" +%F`
fi
sql="
drop table test.tmp;
create table test.tmp as select shopid, shopname, cityid, cityName, regionid, regionname, start_date, end_date, '1' as tag from test.shops_org_zipper where end_date < '$do_date'
union all
select shopid, shopname, cityid, cityName, regionid, regionname, start_date, '9999-12-31' as end_date, '2' as tag from test.shops_org_zipper where start_date <= '$do_date' and end_date >= '$do_date'; "
hive -e "$sql"
```

```
sh rollbackshopszipper.sh 2020-07-12
```

##### 拉链表回滚后

![image-20210818095211871](images\image-20210818095211871.png)

### part2

#### 沉默会员数

只在安装当天启动过App，而且安装时间是在7天前

思路：七天前存在记录,近七天内没有记录

编辑脚本: lastDaies.sh

```shell
#!/bin/bash
source /etc/profile
if [ -n "$1" ]
then daies=$1
else
daies=7
fi
sql="
select count(A.aid) cnt from
(select device_id as aid from dwd.dwd_start_log where dt<date_sub(current_date(),$daies) group by device_id)A
left join 
(select device_id as bid from dwd.dwd_start_log where dt>=date_sub(current_date(),$daies) group by device_id)B
on A.aid=B.bid
where B.bid is null; "
hive -e "$sql"
```

```shell
sh lastDaies.sh 7
```



#### 流失会员数

最近30天未登录的会员

思路同上: 30天前存在记录,近30天内没有记录

```shell
sh lastDaies.sh 30
```

### part3

思路：设计一张dwd层表 dwd.dwd_trade_orders 将ods层数据去重保证每个订单保留一条记录

```sql
drop table if exists dwd.dwd_trade_orders;
create table dwd.dwd_trade_orders(
`orderid` string,
`totalmoney` decimal(10,0),
`createtime` string
)
partitioned by(year string,month string)
STORED AS parquet;

-- 导入数据
with tmp as(
select orderid,totalmoney,createtime,year(createtime)as year,month(createtime) as month from(
select orderid,totalmoney,from_unixtime(unix_timestamp(createtime),'yyyy-MM-dd') as createtime,
row_number() over(cluster by orderid) as rn
from ods.ods_trade_orders where year(createtime)=2020)tmp
where rn=1)
insert overwrite table dwd.dwd_trade_orders
partition(year,month)
select * from tmp;
```

```
<!--添加动态分区支持 -->
<property>
     <name>hive.exec.dynamic.partition</name>
     <value>true</value>
     <description>Whether or not to allow dynamic partitions in DML/DDL.</description>
 </property>
 <200b>
  <property>
     <name>hive.exec.dynamic.partition.mode</name>
     <value>nonstrict</value>
     <description>
       In strict mode, the user must specify at least one static partition
       in case the user accidentally overwrites all partitions.
       In nonstrict mode all partitions are allowed to be dynamic.
     </description>
 </property>
 <property>
     <name>hive.exec.max.dynamic.partitions</name>
     <value>1000</value>
     <description>Maximum number of dynamic partitions allowed to be created in total.</description>
 </property>
 <property>
     <name>hive.exec.max.dynamic.partitions.pernode</name>
     <value>100</value>
     <description>Maximum number of dynamic partitions allowed to be created in each mapper/reducer node.</description>
 </property>
```

#### 统计2020年每个季度的销售订单笔数、订单总额

思路：季度月份分别为 1、4、7、10

```
select count(orderid) totalCount,sum(totalmoney) totalMoney from dwd.dwd_trade_orders where year=2020 and month<4;
select count(orderid) totalCount,sum(totalmoney) totalMoney from dwd.dwd_trade_orders where year=2020 and month>=4 and month <7;
select count(orderid) totalCount,sum(totalmoney) totalMoney from dwd.dwd_trade_orders where year=2020 and month>=7 and month <10;
select count(orderid) totalCount,sum(totalmoney) totalMoney from dwd.dwd_trade_orders where year=2020 and month>=10;
```

#### 统计2020年每个月的销售订单笔数、订单总额

```
select month,count(orderid) totalCount,sum(totalmoney) totalMoney from dwd.dwd_trade_orders where year=2020 group by month;
```

#### 统计2020年每周（周一到周日）的销售订单笔数、订单总额

思路：weekofyear 是返回当前日期是本年的第几周，group by weekofyear(createtime) 即是按每周统计

```
select weekofyear(createtime) weekid,count(orderid) totalCount,sum(totalmoney) totalMoney from dwd.dwd_trade_orders where year=2020 group by weekofyear(createtime);
```

####  统计2020年国家法定节假日、休息日、工作日的订单笔数、订单总额

思路：维护一张节假日的表(统一将一定年限内的节假日、休息日的起止日期灌入)

```
create table special_day(
`special_day_name` string,
`start_date` string,
`end_date` string
) COMMENT '法定节日表';
```

##### 遇到的问题

表连接对于非=报如下异常:

```shell
FAILED: SemanticException Cartesian products are disabled for safety reasons. If you know what you are doing, please sethive.strict.checks.cartesian.product to false and that hive.mapred.mode is not set to 'strict' to proceed. Note that if you may get errors or incorrect results if you make a mistake while using some of the unsafe features.
```

需要先进行以下设置

```shell
set hive.strict.checks.cartesian.product=false
set hive.mapred.mode=nonstrict
```



```sql
-- 统计法定节假日的订单笔数、订单总额
select count(a.orderId) totalCount,sum(a.totalMoney) totalMoney
from dwd.dwd_trade_orders a 
join dwd.special_day b on b.start_date<=a.createtime and a.createtime<=b.end_date;

-- 统计工作日订单笔数、订单总额
select count(a.orderId) totalCount,sum(a.totalMoney) totalMoney
from dwd.dwd_trade_orders a 
left join dwd.special_day b on b.start_date<=a.createtime and a.createtime<=b.end_date
where b.special_day_name is null;
```

