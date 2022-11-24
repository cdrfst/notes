## 简介

  Ansible 是一个开源的基于 OpenSSH 的自动化配置管理工具。可以用它来配置系统、部署软件和编排更高级的 IT 任务，比如持续部署或零停机更新。Ansible 的主要目标是简单和易用，并且它还高度关注安全性和可靠性。基于这样的目标，Ansible 适用于开发人员、系统管理员、发布工程师、IT 经理，以及介于两者之间的所有人。Ansible 适合管理几乎所有的环境，从拥有少数实例的小型环境到有数千个实例的企业环境。

  使用 Ansible 无须在被管理的机器上安装代理，所以不存在如何升级远程守护进程的问题，也不存在由于卸载了守护进程而无法管理系统的问题。

## 主要功能

**管理员可以通过 Ansible 在成百上千台计算机上同时执行指令(任务)。**  
  对于管理员来说，经常需要执行下面的任务：

  维护现存的比较复杂的服务器时，手动登录的方式很容易遗漏一些操作，或者是执行一些未预期的操作。  
  手动初始化新的服务器耗时耗力！  
  对于这两种情况，如果完全通过 shell 脚本实现。脚本会过于复杂，极难维护。当然我们也可以使用同类的工具，比如 Puppet and Chef。这两个工具的特点是：需要学习新的知识栈(其实 Ansible 也是有学习成本的)。

  相比 Puppet 和 Chef 使用 Ansible 可以延续之前使用 shell 脚本的工作习惯和方式，因而其学习成本会低一些。下面是 Ansible 的一些优势：  
  1、可以逐行的执行 shell 命令。  
  2、不需要另外的客户端工具(linux 一般会自带 ssh 工具)。  
  3、相同的配置只被执行一次(多次执行同一配置不会出问题)。  
  但是因为许多服务器都是在内网环境，我们想安装Ansible就不是很便捷，所以就整合了下面的安装包，方便在离线环境进行安装

## 离线安装准备




## 集群安装前准备

配置DNS服务器用于主机名解析或者更新所有集群服务器/etc/hosts
本机/远程节点必须可以ssh登陆

## Ansible 配置
### ansible.cfg
路径：/etc/ansible/ansible.cfg
``` shell
vi /etc/ansible/ansible.cfg
[defaults]
forks          = 8           #执行时并发数
host_key_checking = False    #不检测host key
```

### 修改/etc/ansible/hosts
``` shell
#备份
cp /etc/ansible/hosts{,.bak}

vi /etc/ansible/hosts
# ansible_user=root
# ansible_ssh_pass=123456
# ansible_port=22

```

``` shell
# 在管理机器上执行以下指令
-m 指定功能模块，默认就是command模块
-a 模块将要执行的参数
-k 询问密码
-u 指定运行的用户
ansible 分组名 -m command -a "hostname" -k -u root
```

## 模式
- ad-hoc
	简单命令行
+ playbook
	复杂脚本


## 列出所有ansible支持的模块
```shell
ansible-doc -l
```

### 常用模块
+ command
	不支持shell变量 ($name) > < | ; & 如需要使用前面这些符号请使用shell模块
+ shell
	在远程机器上执行命令(复杂命令),命令脚本必须存在于远程机器上
+ script
	命令脚本仅存在于控制机器上

## 查看某个模块的具体用法
```shell
[ecm@ecm-11 ~]$ ansible-doc -s command
- name: Execute commands on targets
  command:
      argv:                  # Passes the command as a list rather than a string. Use `argv' to
                               avoid quoting values that would
                               otherwise be interpreted incorrectly
                               (for example "user name"). Only the
                               string or the list form can be
                               provided, not both.  One or the other
                               must be provided.
      chdir:                 # Change into this directory before running the command.
      cmd:                   # The command to run.
      creates:               # A filename or (since 2.0) glob pattern. If it already exists, this
                               step *won't* be run.
      free_form:             # The command module takes a free form command to run. There is no
                               actual parameter named 'free form'.
      removes:               # A filename or (since 2.0) glob pattern. If it already exists, this
                               step *will* be run.
      stdin:                 # Set the stdin of the command directly to the specified value.
      stdin_add_newline:     # If set to `yes', append a newline to stdin data.
      strip_empty_ends:      # Strip empty lines from the end of stdout/stderr in result.
      warn:                  # Enable or disable task warnings.

```




