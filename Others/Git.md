

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



