
## 拉取指定分支版本

``` shell
git clone --branch [tags标签] [git地址]
```

``` shell
git clone -b v0.6.7 --depth=1 https://github.com/DataLinkDC/dlink.git
```

``` shell
-b 后面写上指定 版本标签
--depth 表示克隆深度, 1 表示只克隆最新的版本. 因为如果项目迭代的版本很多, 克隆会很慢
```


## SSH配置

### 单个用户配置

``` shell
git config --global user.name "cdxx" 
git config --global user.email "22369xxxx@qq.com"
```

### 生成SSH文件

``` shell
ssh-keygen -t rsa -C "22369xxxx@qq.com"
```

代码参数的含义：

-t：执行密钥类型，默认是rsa，可以省略

-C：设置注释文字，比如邮箱

-f：指定密钥文件存储文件名

以上代码省略了-f参数，因此运行上面那条命令之后会让你输入一个文件名.

### 新建config文件
	在 `~/.ssh` 目录下新建一个config文件，添加如下内容
```shell
#gitee
#Host gitee.com
#HostName gitee.com
#User xxxxx
#PreferredAuthentications publickey
#IdentityFile ~/.ssh/gitee_id_rsa

#github
Host github.com
HostName github.com
User cdrfst
PreferredAuthentications publickey
IdentityFile ~/.ssh/id_rsa

```
此时 ~/.ssh 目录下有如下文件
```shell
config      
github_rsa.pub  
id_rsa.pub   
known_hosts.old
github_rsa  
id_rsa          
known_hosts
```

### 代理设置
```shell
#全局设置
git config --global https.proxy http://127.0.0.1:1080
git config --global https.proxy https://127.0.0.1:1080
#取消全局代理
git config --global --unset http.proxy
git config --global --unset https.proxy

#只对github.com
git config --global http.https://github.com.proxy socks5://127.0.0.1:1080
#取消代理
git config --global --unset http.https://github.com.proxy)

```

### 遇到的问题
```shell
stepb@PVE-DESKTOP MINGW64 /d/git/notes (main)
$ ssh -T git@github.com
Hi cdrfst! You\'ve successfully authenticated, but GitHub does not provide shell access.

#解决办法把远程clone的url改成ssh的,执行如下指令后上面的测试指令依然报错但却可以git push了
git remote set-url origin git@github.com:cdrfst/notes.git

```

## 命令

暂存区：存取、删除
命令	说明
git add.、git stash	提交到暂存区
git stash	暂存工作区修改的内容：保存到暂存区（可以提N次）
git stash pop	恢复暂存的工作区内容：从暂存区取出（最近一次）
git stash list	查询工作区所有stash的列表
git stash apply stash@{2}	查询后，恢复第二次提交的
git stash clear	清空暂存区的所有stash


