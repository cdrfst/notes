# 用户管理

+ 判断用户是否存在
``` shell
getent passwd root
```
+ 判断用户组是否存在
``` shell
[ecm@ecm-13 ~]$ getent group ecm
ecm:x:1000:ecm

```

# 组管理

## 主组和辅助组

给用户添加辅助组: 
	建议使用`gpasswd`命令而不是`usermod`，因为`usermod -G`命令如果不写全用户的附属组，会清空之前的所有附属组

```shell
gpasswd -a tiaf sudoer
```


# sudo
## 安装sudo

```shell
apt-get update
apt-get install sudo
```

## 将用户添加到sudo组中
```shell
sudo gpasswd -a user sudo
```
