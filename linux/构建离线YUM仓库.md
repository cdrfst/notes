# 方式一:下载完整仓库(未完)

- 在可连接外网机器上操作
```shell
# 安装必备工具
yum -y install yum-utils

```

- 下载相应构架和repoid的完整rpm包
```shell
# 下载aarch64架构的epel完整包
reposync -n --repoid=epel --arch=aarch64 -p /root/epelofflineaarch64/

```

# 方式二:下载全量依赖 rpm 包及离线安装

## 查看依赖包

查看ansible的依赖包

```shell
yum deplist ansible 

```

## **repotrack**(推荐)

```shell
# 下载 ansible 全量依赖包 
repotrack ansible

```
**推荐
` 此方法会下载全量依赖包

##  yumdownloader

```shell
# 安装yum-utils $ yum -y install yum-utils 
# 下载 ansible 依赖包 
yumdownloader --resolve --destdir=/tmp ansible

```

参数说明：

- —destdir：指定 rpm 包下载目录（不指定时，默认为当前目录）
- —resolve：下载依赖的 rpm 包。

**注意**
`仅会将主软件包和基于你现在的操作系统所缺少的依赖关系包一并下载。

## yum 的 downloadonly 插件

```shell
yum -y install ansible --downloadonly --downloaddir=/tmp

```
**注意**
`与 yumdownloader 命令一样，也是仅会将主软件包和基于你现在的操作系统所缺少的依赖关系包一并下载。 如果已经安装则什么都不会下载!!!

## 离线安装rpm

```shell
# 离线安装 
rpm -Uvh --force --nodeps *.rpm

```
