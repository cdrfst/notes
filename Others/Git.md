拉取指定分支版本
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


`
