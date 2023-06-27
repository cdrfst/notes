[参考官方](https://kafka.apache.org/documentation/#upgrade)

-  执行脚本在所有Broker的配置文件server.properties中添加如下属性：
```shell
# refers to the version you are upgrading from

CURRENT_KAFKA_VERSION=2.8.1
inter.broker.protocol.version=2.8.1

```
- 重启所有Broker
- 依次在单个Broker节点执行以下脚本:
```shell
#!/bin/bash

# 使用jps查找kafka进程ID
KAFKA_PID=$(jps | grep Kafka | awk '{print $1}')

# 如果找到了kafka进程，则结束该进程
if [ -n "$KAFKA_PID" ]
then
    echo "Kafka process found. PID: $KAFKA_PID"
    kill -TERM $KAFKA_PID
    echo "Waiting for Kafka process to exit..."
    
    # 使用wait命令等待进程结束
    while kill -0 $KAFKA_PID >/dev/null 2>&1; do
        sleep 1
    done

    echo "Kafka process terminated. PID: $KAFKA_PID"
else
    echo "Kafka process not found."
fi

echo "Ok"

# 解压 kafka_3.4.tgz 文件
if [ -f ./kafka_3.4.tgz ]
then
    echo "Unpacking kafka_3.4.tgz..."
    tar xzf kafka_3.4.tgz
else
    echo "kafka_3.4.tgz not found."
fi

# 如果解压成功，则复制 server.properties 文件
if [ -d ./kafka_3.4 ]
then
    if [ -f ./kafka_2.8.1/config/server.properties ]
    then
        echo "Copying server.properties to kafka_3.4/config/..."
        cp ./kafka_2.8.1/config/server.properties ./kafka_3.4/config/
    else
        echo "server.properties not found."
    fi
else
    echo "kafka_3.4 directory not found."
fi


```

修改环境变量为新版本kafka文件夹
``` shell
# 编辑 ~/.bash_profile 文件，将 $KAFKA_HOME 设置为新的 Kafka 文件夹
if [ -f ~/.bash_profile ]
then
    echo "Updating $KAFKA_HOME in ~/.bash_profile..."
    sed -i.bak 's|export KAFKA_HOME=.*|export KAFKA_HOME='$(pwd)'/kafka_3.4|' ~/.bash_profile
else
    echo "~/.bash_profile not found."
fi

# 使更改立即生效
source ~/.bash_profile
echo "KAFKA_HOME updated to: $KAFKA_HOME"

```

- 上述步骤分别在每个Broker完成后检查一下集群和数据是否正常，此时还可以恢复到原来版本如果一切正常则继续
1. 1.  Once the cluster's behavior and performance has been verified, bump the protocol version by editing `inter.broker.protocol.version` and setting it to `3.4`.
```
inter.broker.protocol.version=3.4
```
1. Restart the brokers one by one for the new protocol version to take effect. Once the brokers begin using the latest protocol version, it will no longer be possible to downgrade the cluster to an older version.

6. 如需要将文件夹修改请同步修改环境变量 $KAFKA_HOME

有三台配置了互信的主机分别是 node1 node2 node3 ，请编写一个Shell 脚本实现以下功能：
1.检查 $KAFKACONF 变量指向的配置文件 前两行是否存在 属性  CURRENT_KAFKA_VERSION=2.8.1
和 inter.broker.protocol.version=2.8.1 如果存在则不做操作，不存在则加上，注意在操作前备份一下配置文件，备份文件名以日期后缀命名