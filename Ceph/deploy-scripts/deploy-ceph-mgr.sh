#!/bin/bash

source ./deploy-base.sh

#确认本机IP
HOST_NAME=`hostname -s`
MGR_DIR=/var/lib/ceph/mgr/$CLUSTER_NAME-$HOST_NAME
MGR_KEYRING=$MGR_DIR/keyring



#确认变量信息
echo "HOST_NAME $HOST_NAME"
echo "MGR_DIR $MGR_DIR"
echo "MGR_KEYRING $MGR_KEYRING"
echo "user $user"


confirm_execution "确认以上变量值是否正确？y/n" "用户选择了否。"

if [ $? -eq 0 ]; then
    # 继续执行需要执行的操作
	echo "continue..."
else
    # 执行其他操作或退出脚本
    echo "退出脚本..."
    exit 1
fi

#生成mon密钥
execute_command "create_folder $MGR_DIR" "创建mgr数据目录失败"
execute_command "sudo chown -R ceph:ceph $MGR_DIR" "设置密钥$MGR_DIR 所有者和所属组失败"

execute_command "sudo setfacl -Rm u:$user:rwx /var/lib/ceph" "无法为用户 $user 添加Ceph默认目录的[读、写、执行]权限"

execute_command "sudo ceph auth get-or-create mgr.$HOST_NAME mon 'allow profile mgr' osd 'allow *' mds 'allow *' > $MGR_KEYRING" "生成mgr密钥失败"
execute_command "sudo chown -R ceph:ceph $MGR_KEYRING" "设置密钥$MGR_KEYRING 所有者和所属组失败"

execute_command "sudo ceph-mgr -i $HOST_NAME --setuser ceph --setgroup ceph" "启动mgr失败"


execute_command "sudo systemctl start ceph-mgr@$HOST_NAME" "启动mgr服务失败"

execute_command "sudo systemctl enable ceph-mgr@$HOST_NAME" "设置mgr服务自启动失败"

script_name=$(basename "$0")
echo "当前脚本执行完成$script_name"
