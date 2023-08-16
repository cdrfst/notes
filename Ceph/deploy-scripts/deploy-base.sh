#!/bin/bash
#set -o nounset（或set -u）命令开启了nounset选项，那么在使用未声明的变量时，会导致脚本终止并报错
set -u
set -e

RED='\e[31m'
RESET='\e[0m'

#此句输出红色
#echo -e "${RED}This is red text${RESET}"



OP_USER="$USER"
#集群ID，必须与/etc/ceph/ceph.conf中的fsid保持一致
CLUSTER_ID='a7f64266-0894-4f1e-a635-d0aeaca0e993';
CLUSTER_NAME="ceph"
ADMIN_KEYRING=/etc/ceph/ceph.client.admin.keyring
user=$USER

# Function to execute command with error handling
execute_command() {
    local command=$1
    local error_message=$2

    echo "执行命令：$command"
    if ! eval "$command"; then
        echo "发生错误：$error_message"
        exit 1
    fi
}



# 定义确认函数
confirm_execution() {
    local message=$1
    local log_message=$2

    # 提示用户确认
    read -p "$message (y/n): " choice

    # 判断用户输入
    if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
        echo "继续执行..."
        # 执行需要继续执行的操作
        return 0
    else
        echo "结束执行，并打印日志..."
        # 打印日志或执行其他操作
        echo "$log_message"
        return 1
    fi
}

# 使用确认函数
#confirm_execution "是否继续执行？" "用户选择了不继续执行。"

: '
# 检查确认函数的返回值
if [ $? -eq 0 ]; then
    # 继续执行需要执行的操作
    echo "继续执行操作..."
else
    # 执行其他操作或退出脚本
    echo "执行其他操作或退出脚本..."
    exit 1
fi
'


create_folder() {
  folder="$1"
  
  if [ ! -d "$folder" ]; then
    sudo -u ceph mkdir "$folder"
    echo "文件夹 $folder 创建成功"
  else
    echo "文件夹 $folder 已经存在"
  fi
}
: '
# 调用函数
create_folder "/path/to/folder"
'

check_exist() {
    if [ -e "$1" ]; then
        echo "File or directory '$1' exists."
        read -p "Do you want to delete it? (y/n): " choice
        case "$choice" in
            y|Y )
                rm -rf "$1"
                echo "File or directory '$1' deleted."
                ;;
            n|N )
                echo "File or directory '$1' not deleted."
                ;;
            * )
                echo "Invalid choice. File or directory '$1' not deleted."
                ;;
        esac
    else
        echo "File or directory '$1' does not exist."
    fi
}
