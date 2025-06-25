
### 编译fuse_dfs
#### 安装 fuse 相关依赖
此依赖一般系统都有
```shell
# yum list | grep fuse
yum install fuse fuse-devel fuse-libs
```
#### 安装编译依赖
```shell
yum install -y cmake3 gcc-c++
ln -s /usr/bin/cmake3 /usr/bin/cmake
```

#### 编译fuse_dfs
```shell
mvn clean package -pl hadoop-3.2.4-src/hadoop-hdfs-project/hadoop-hdfs-native-client -Pnative -DskipTests -Drequire.fuse=true
```

## 挂载
#### 配置环境变量
```shell
#java
export JAVA_HOME=/app/software/jdk1.8.0_77
export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib:$JAVA_HOME/jre/lib:$CLASSPATH

#hadoop
export HADOOP_HOME=/app/software/hadoop-3.2.4
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

#fuse_dfs
export OS_ARCH=amd64
export LD_LIBRARY_PATH=$JAVA_HOME/jre/lib/$OS_ARCH/server:$HADOOP_HOME/lib/native
export CLASSPATH=$CLASSPATH:`$HADOOP_HOME/bin/hadoop classpath --glob`

```

#### 挂载
```shell
mkdir /mnt/hdfs1
chown tiaf:tiaf /mnt/hdfs1
chown tiaf:tiaf /etc/fuse.conf
vi /etc/fuse.conf #将里面的两行注释项取消注释
fuse_dfs hdfs://tiaf-a:9000/ /mnt/hdfs1
```


### 卸载挂在点
```shell
fusermount -u /mnt/hdfs1
```