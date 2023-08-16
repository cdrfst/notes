#!/bin/bash

source ./deploy-base.sh


echo "当前用户 $user"

confirm_execution "确认以上变量值是否正确？y/n" "用户选择了否。"

#路径存在则设置响应权限
set_permission(){
if [ -e "$1" ]; then
        eval "$2"
    else
        echo "File or directory '$1' does not exist."
    fi
}

if [ $? -eq 0 ]; then
    # 继续执行需要执行的操作
	echo "continue..."
else
    # 执行其他操作或退出脚本
    echo "退出脚本..."
    exit 1
fi


set_permission "/var/lib/ceph" "sudo chown -R ceph:ceph /var/lib/ceph"
set_permission "/var/log/radosgw" "sudo chown -R ceph:ceph /var/log/radosgw"
set_permission "/var/run/ceph" "sudo chown -R ceph:ceph /var/run/ceph"
set_permission "/etc/ceph" "sudo chown -R ceph:ceph /etc/ceph"
set_permission "/var/log/ceph" "sudo chown -R ceph:ceph /var/log/ceph"
set_permission "/var/lib/ceph" "sudo setfacl -Rm u:$user:rwx /var/lib/ceph"
set_permission "/var/run/ceph" "sudo setfacl -Rm u:$user:rwx /var/run/ceph"
set_permission "/etc/ceph" "sudo setfacl -Rm u:$user:rwx /etc/ceph"
set_permission "/var/log/ceph" "sudo setfacl -Rm u:$user:rwx /var/log/ceph"
set_permission "/var/log/radosgw" "sudo setfacl -Rm u:$user:rwx /var/log/radosgw"
