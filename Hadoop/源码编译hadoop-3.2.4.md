# 编译环境
## Centos 7.9 Minimal-2207-02
# 依赖安装

## jdk1.8
## maven3.8.4
## 软件源配置为阿里云

## 建议使用此顺序，否则可能出现依赖问题
```shell
sudo yum install -y gcc gcc-c++
sudo yum install -y make
sudo yum install -y autoconf automake libtool curl
sudo yum install -y lzo-devel zlib-devel openssl openssl-devel ncurses-devel
sudo yum install -y snappy snappy-devel bzip2 bzip2-devel lzo lzo-devel lzop libXtst
sudo yum install -y patch
```

## Protobuf-2.5.0 (同3.7.1)

```shell
tar -zxvf protobuf-2.5.0.tar.gz
cd protobuf-2.5.0
sudo mkdir -p /usr/local/protobuf
./configure --prefix=/usr/local/protobuf
sudo make 
sudo make check #检测完成之后使用echo $?验证，返回0则表示成功
sudo make install
```

**配置共享库运行时的动态链接器。当系统安装了新的共享库文件时，ldconfig命令可以更新系统的共享库缓存，使得系统能够正确地找到和加载**
```shell
ldconfig
```

**测试是否可用**
```shell
/usr/local/protobuf/bin/protoc --version
```

- 添加到环境变量
```shell
vim /etc/profile
export PROTOBUF_HOME=/usr/local/protobuf/
export PATH=$PATH:$PROTOBUF_HOME/bin
```
**刷新当前会话**
```shell
source /etc/profile
```

## 安装CMake-3.19.4

```shell
# 解压
sudo tar -xvf cmake-3.19.4-Linux-x86_64.tar.gz -C /opt/
# 而后构建链接
sudo ln -s /opt/cmake-3.19.4-Linux-x86_64/bin/cmake /usr/bin/cmake
```

## 安装Snappy-1.1.3

```shell
#上传解压
tar zxvf snappy-1.1.3.tar.gz 

#编译安装
cd snappy-1.1.3
sudo ./configure
sudo make ;sudo make install

#验证是否安装
sudo ls -lh /usr/local/lib |grep snappy
-rw-r--r-- 1 root root 511K Nov  4 17:13 libsnappy.a
-rwxr-xr-x 1 root root  955 Nov  4 17:13 libsnappy.la
lrwxrwxrwx 1 root root   18 Nov  4 17:13 libsnappy.so -> libsnappy.so.1.3.0
lrwxrwxrwx 1 root root   18 Nov  4 17:13 libsnappy.so.1 -> libsnappy.so.1.3.0
-rwxr-xr-x 1 root root 253K Nov  4 17:13 libsnappy.so.1.3.0
```


# 开始编译

## Hadoop

```shell
mvn clean package -Pdist,native -DskipTests -Dtar -Dbundle.snappy -Dsnappy.lib=/usr/local/lib
```

## Hbase
**默认依赖hadoop2.10.2编译，此处指定-Dhadoop.profile=3.0表示依赖hadoop3.x(具体版本和不同hbase源码版本有关请查看其根pom.xml文件)**
```shell
mvn clean package -DskipTests assembly:single -Dhadoop.profile=3.0
```

## Hbase Operator Tools

```shell
mvn clean package
```

参数说明：
Pdist,native ：把重新编译生成的hadoop动态库；
DskipTests ：跳过测试
Dtar ：最后把文件以tar打包
Dbundle.snappy ：添加snappy压缩支持【默认官网下载的是不支持的】
Dsnappy.lib=/usr/local/lib ：指snappy在编译机器上安装后的库路径


# 编译报错：

## 安装身份验证组件
CMake Error at main/native/libhdfspp/CMakeLists.txt:135 (message):
[WARNING]   Cound not find a SASL library (GSASL (gsasl) or Cyrus SASL (libsasl2).
[WARNING]   Install/configure one of them or define NO_SASL=1 in your cmake call
解决办法：
**（已经安装了cyrus 则不需要）**
```shell
yum install -y cyrus-sasl*
```

## 报以下错误但不影响编译
```shell
[INFO] 
[INFO] --- exec-maven-plugin:1.3.1:exec (toolshooks) @ hadoop-dist ---
ERROR: hadoop-aliyun has missing dependencies: org.jacoco.agent-runtime.jar
ERROR: hadoop-resourceestimator has missing dependencies: hadoop-yarn-common-3.2.4.jar
ERROR: hadoop-resourceestimator has missing dependencies: hadoop-hdfs-client-3.2.4.jar
ERROR: hadoop-resourceestimator has missing dependencies: okhttp-2.7.5.jar
ERROR: hadoop-resourceestimator has missing dependencies: okio-1.6.0.jar
ERROR: hadoop-resourceestimator has missing dependencies: jersey-client-1.19.jar
ERROR: hadoop-resourceestimator has missing dependencies: guice-servlet-4.0.jar
ERROR: hadoop-resourceestimator has missing dependencies: guice-4.0.jar
ERROR: hadoop-resourceestimator has missing dependencies: aopalliance-1.0.jar
ERROR: hadoop-resourceestimator has missing dependencies: jersey-guice-1.19.jar
ERROR: hadoop-resourceestimator has missing dependencies: jackson-module-jaxb-annotations-2.10.5.jar
ERROR: hadoop-resourceestimator has missing dependencies: jakarta.xml.bind-api-2.3.2.jar
ERROR: hadoop-resourceestimator has missing dependencies: jakarta.activation-api-1.2.1.jar
ERROR: hadoop-resourceestimator has missing dependencies: jackson-jaxrs-json-provider-2.10.5.jar
ERROR: hadoop-resourceestimator has missing dependencies: jackson-jaxrs-base-2.10.5.jar
ERROR: hadoop-resourceestimator has missing dependencies: hadoop-yarn-api-3.2.4.jar
ERROR: hadoop-resourceestimator has missing dependencies: hadoop-yarn-server-resourcemanager-3.2.4.jar
ERROR: hadoop-resourceestimator has missing dependencies: hadoop-yarn-server-common-3.2.4.jar
ERROR: hadoop-resourceestimator has missing dependencies: hadoop-yarn-registry-3.2.4.jar
ERROR: hadoop-resourceestimator has missing dependencies: commons-daemon-1.0.13.jar
ERROR: hadoop-resourceestimator has missing dependencies: geronimo-jcache_1.0_spec-1.0-alpha-1.jar
ERROR: hadoop-resourceestimator has missing dependencies: ehcache-3.3.1.jar
ERROR: hadoop-resourceestimator has missing dependencies: HikariCP-java7-2.4.12.jar
ERROR: hadoop-resourceestimator has missing dependencies: hadoop-yarn-server-applicationhistoryservice-3.2.4.jar
ERROR: hadoop-resourceestimator has missing dependencies: objenesis-1.0.jar
ERROR: hadoop-resourceestimator has missing dependencies: fst-2.50.jar
ERROR: hadoop-resourceestimator has missing dependencies: java-util-1.9.0.jar
ERROR: hadoop-resourceestimator has missing dependencies: json-io-2.5.1.jar
ERROR: hadoop-resourceestimator has missing dependencies: hadoop-yarn-server-web-proxy-3.2.4.jar
ERROR: hadoop-resourceestimator has missing dependencies: bcprov-jdk15on-1.60.jar
ERROR: hadoop-resourceestimator has missing dependencies: bcpkix-jdk15on-1.60.jar
ERROR: hadoop-resourceestimator has missing dependencies: leveldbjni-all-1.8.jar
ERROR: hadoop-resourceestimator has missing dependencies: javax.inject-1.jar
Rewriting /root/hadoop-3.2.4-src/hadoop-dist/target/hadoop-3.2.4/etc/hadoop/hadoop-env.sh
```