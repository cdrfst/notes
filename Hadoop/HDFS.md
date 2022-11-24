## 新集群启动顺序

步驟：
1. hadoop-daemon.sh start journalnode
2. 在主namenode上执行 hdfs namenode -format
3. 在主namenode上执行  hadoop-daemon.sh start namenode
4. 在未格式化的namenode上执行 hdfs namenode -bootstrapStandby
5. 在主namenode上执行 hdfs zkfc -formatZK
6. start-dfs.sh
7. 在resourceManager节点上执行 start-yarn.sh

## 遇到的问题

### 两个namenode节点状态都是standby状态
背景描述：
	在启动YARN之前改了 core-site.xml中的 fs.defaultFs 和 hdfs-site.xml 中的 dfs.nameservices
	
初步判断：
1. master1可互信访问所有节点，但master2不能
+ 为master2加了到其它节点的互信后依然不行

解决办法：
停止hdfs服务后在主namenode节点上 执行 hdfs zkfc -formatZK

### hdfs java.net.UnknownHostException
背景描述：
	刚启动完hdfs后执行命令“hdfs dfs -ls" 时报 UnknownHostException 提示找不到"hdfs-media"主机
其中 core-site.xml配置如下：
``` shell
<property>
            <name>fs.defaultFS</name>
            <value>hdfs://hdfs-media</value>
         </property>

```

初步判断：
	开始觉得需要将 hdfs-media配置进/etc/hosts中，但回头想想我是想让我当前集群的名字叫hdfs-media，不应该固定成某个ip
	
解决办法：
也需要在hdfs-site.xml中配置如下：
``` shell
<!-- common configue for NN_HA  -->

        <property>
                <name>dfs.nameservices</name>
                <value>hdfs-media</value>
        </property>
        <property>
                <name>dfs.ha.namenodes.hdfs-media</name>
                <value>nn1,nn2</value>
        </property>
        <property>
                <name>dfs.namenode.rpc-address.hdfs-media.nn1</name>
                <value>ecm-13:9000</value>
        </property>
        <property>
                <name>dfs.namenode.http-address.hdfs-media.nn1</name>
                <value>ecm-13:50070</value>
        </property>
        <property>
                <name>dfs.namenode.rpc-address.hdfs-media.nn2</name>
                <value>ecm-12:9000</value>
        </property>
        <property>
                <name>dfs.namenode.http-address.hdfs-media.nn2</name>
                <value>ecm-12:50070</value>
        </property>
<!-- namenode configue for NN_HA -->

        <property>
                <name>dfs.namenode.shared.edits.dir</name>
                <value>qjournal://ecm-13:8485;ecm-12:8485;ecm-11:8485/hdfs-media</value>
        </property>

```

### 其它问题

+ start-dfs.sh时报JournalNotFormattedException  (前提已经分别启动了JournalNode节点)
	该异常处理三种类型：
	1. 类型一：
		当你从异常信息中看到JournalNode not formatted，如果在异常中看到三个节点都提示需要格式化JournalNode。
		如果你是新建集群，你可以重新格式化NameNode,同时你会发现，JournalNode的目录被格式化…
	2. 类型二：
		如果只是其中一个JournalNode没有被格式化，那么首先检查你的JournalNode目录权限是否存在问题，然后从其他JournalNode复制一份到没有格式化的JournalNode。
	3. 类型三：
		如果你从一个no-HA更新到HA，you can do this …
		hdfs namenode -initializeSharedEdits
		也就是你可以不用格式化NameNode就可以格式化你的JournalNode目录


+ hdfs --daemon start zkfc 时报错：
 /tmp/hadoop-xxx(username)-datanode.pid: Permission denied
修改hadoop-env.sh文件，添加export HADOOP_PID_DIR=/usr/local/hadoop/tmp/pid  同时记得在slave节点里也修改这一项，我开始的就是没有改slave节点里的HADOOP_PID_DIR 导致 检查了好久都不对







