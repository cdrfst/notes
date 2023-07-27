# shell 笔记

## sh xx.sh与exec xx.sh区别
### 前者

## export 变量(a) 作用、生命周期及应用场景
### 作用：变量共享
### 生命周期：本进程及子进程中可访问
### 应用场景：脚本间传值 

## 函数定义及调用
test(){
echo `date +%Y-%M-%D" "%H:%M:%S`" "$*
}
>test abc
>echo 2022-07-16 06:01:55 abc

## 将命令在远程机器执行并接收返回结果
### 框架：变量=`执行命令`
eg:
>result=`ssh ecm@ecm-node-8 "hostname;echo 123"`
>echo $result
>ecm-node-8 123

## 指令分隔符
;(分号)
&&(两个的Shift+7)

## 返回上一条指令执行结果
$?
### 判断上一条命令执行失败后打印日志
[! $? eq 0]&&echo "xx命令执行失败"

## 计算表达式的值
### 将表达式放在$[表达式]
eg:
>a=$[3-1]
>echo $a
>2
