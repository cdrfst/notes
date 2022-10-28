Docker分两个版本：

CE(Community Edition)
EE(Enterprise Edition)
CE版本是免费的，如果我们学习或者一般应用，CE足够。
EE版本在安全性上有很大提升，是收费版本，可以试用一定时间。

安装方式：
一、yum 安装 docker-
yum介绍
Yum（全称为 Yellow dog Updater, Modified）是一个在 Fedora和RedHat以及CentOS中的Shell前端软件包管理器。

基于RPM包管理，能够从指定的服务器自动下载RPM包并且安装，可以自动处理依赖性关系，并且一次安装所有依赖的软件包，无须繁琐地一次次下载、安装。

#1 卸载旧版本

较旧的Docker版本称为docker或docker-engine。如果已安装这些程序，请卸载它们以及相关的依赖项。
``` shell
sudo yum docker, docker-client, docker-common

sudo yum remove docker, docker-client, docker-client-latest, docker-common, docker-latest , docker-latest-logrotate, docker-logrotate , docker-engine
```

#2 更新yum
此条命令升级所有包还有内核
``` shell
yum -y update
```
如不升级内核则输入以下
``` shell
yum -y upgrade
```

安装必备依赖:
yum-util提供yum-config-manager功能，另外两个是devicemapper驱动依赖的包
``` shell
yum install -y yum-utils device-mapper-persistent-data lvm2
```

添加yum的源
为了安装docker的社区版本，需要给yum添加源，这里提供两种方式:
1.国内源
``` shell
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```

2.官方源
``` shell
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```
这两个源下载的docker-ce.repo是一样的，执行上述其中一条命令后，就生成了 /ect/yum.repos.d/docker-ce.repo 这个文件.

社区版按照stable和edge两种方式发布，每个季度更新stable版本，每个月份更新edge版本。

另外，test版本是预发布版本，也就是下一个大版本的测试作品。

如果需要启动docker-ce-edge，需要执行以下命令:
``` shell
sudo yum-config-manager --enable docker-ce-edge
```
执行完后，再打开文件，可以看到 docker-ce-edge的enabled=1 了。

如果要禁用，通过命令：
``` shell
sudo yum-config-manager --disable docker-ce-edge
```

安装最新的社区版本：
``` shell
sudo yum -y install docker-ce --nobest
```
注：--nobest： use not only best candidate packages

如果在生产环境，往往不是安装最新版本，而是安装指定版本，那么可以先通过如下命令查看版本：
``` shell
yum list docker-ce --showduplicates|sort -r
```

结果如下：
```
docker-ce.x86_64            3:20.10.9-3.el7                    docker-ce-stable
docker-ce.x86_64            3:20.10.8-3.el7                    docker-ce-stable
docker-ce.x86_64            3:20.10.7-3.el7                    docker-ce-stable
docker-ce.x86_64            3:20.10.6-3.el7                    docker-ce-stable
docker-ce.x86_64            3:20.10.5-3.el7                    docker-ce-stable
docker-ce.x86_64            3:20.10.4-3.el7                    docker-ce-stable
docker-ce.x86_64            3:20.10.3-3.el7                    docker-ce-stable
docker-ce.x86_64            3:20.10.2-3.el7                    docker-ce-stable
docker-ce.x86_64            3:20.10.21-3.el7                   docker-ce-stable
docker-ce.x86_64            3:20.10.21-3.el7                   @docker-ce-stable
docker-ce.x86_64            3:20.10.20-3.el7                   docker-ce-stable
docker-ce.x86_64            3:20.10.19-3.el7                   docker-ce-stable
docker-ce.x86_64            3:20.10.18-3.el7                   docker-ce-stable
```


安装指定版本:
``` shell
sudo yum install docker-ce-20.10.21
```


启动docker服务:
``` shell
sudo systemctl start  docker
#查看版本
docker -v
#启动测试应用
sudo docker run hello-world
#开机自启,设置为开机自动激活单元并现在立刻启动
systemctl enable --now docker

```

解决Docker Pull 很慢的方法：
``` shell
##使用阿里云镜像加速器
[root@localhost ~]# mkdir -p /etc/docker
[root@localhost ~]# tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://9cpn8tt6.mirror.aliyuncs.com"]
}
EOF
[root@localhost ~]# systemctl daemon-reload
[root@localhost ~]# systemctl restart docker

```




