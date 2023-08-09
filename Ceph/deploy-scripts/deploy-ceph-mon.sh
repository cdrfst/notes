#!/bin/bash

source ./deploy-base.sh

#确认本机IP
HOST_NAME=`hostname -s`
NODE_IP=`hostname -i`
MON_DIR=/var/lib/ceph/mon/$CLUSTER_NAME-$HOST_NAME
MON_KEYRING=/tmp/ceph.mon.keyring
MONMAP=/tmp/monmap
BOOTSTRAP_OSD_KEYRING=/var/lib/ceph/bootstrap-osd/ceph.keyring


#确认变量信息
echo "HOST_NAME $HOST_NAME"
echo "NODE_IP $NODE_IP"
echo "MON_DIR $MON_DIR"
echo "MON_KEYRING $MON_KEYRING"
echo "MONMAP $MONMAP"
echo "ADMIN_KEYRING $ADMIN_KEYRING"
echo "BOOTSTRAP_OSD_KEYRING $BOOTSTRAP_OSD_KEYRING"


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
execute_command "sudo ceph-authtool --create-keyring $MON_KEYRING --gen-key -n mon. --cap mon 'allow *'" "生成mon密钥失败"
execute_command "sudo chown ceph:ceph $MON_KEYRING" "设置密钥$MON_KEYRING所有者和所属组失败"

execute_command "sudo ceph-authtool --create-keyring $ADMIN_KEYRING --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'" "生成admin密钥失败"
execute_command "sudo chown ceph:ceph $ADMIN_KEYRING" "设置密钥$ADMIN_KEYRING所有者和所属组失败"

execute_command "sudo ceph-authtool --create-keyring $BOOTSTRAP_OSD_KEYRING --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd' --cap mgr 'allow r'" "生成mon密钥失败"
execute_command "sudo chown ceph:ceph $BOOTSTRAP_OSD_KEYRING" "设置密钥$BOOTSTRAP_OSD_KEYRING所有者和所属组失败"

execute_command "sudo ceph-authtool $MON_KEYRING --import-keyring $ADMIN_KEYRING" "将$ADMIN_KEYRING导入到$MON_KEYRING失败"
execute_command "sudo ceph-authtool $MON_KEYRING --import-keyring $BOOTSTRAP_OSD_KEYRING" "将$BOOTSTRAP_OSD_KEYRING导入到$MON_KEYRING失败"


execute_command "sudo monmaptool --create --add $HOST_NAME $NODE_IP --fsid $CLUSTER_ID $MONMAP --clobber" "生成monitor map文件$MONMAP失败"
execute_command "sudo chown ceph:ceph $MONMAP" "设置密钥$MONMAP 所有者和所属组失败"

execute_command "create_folder $MON_DIR" "创建文件夹$MON_DIR失败"

execute_command "sudo -u ceph ceph-mon --mkfs -i $HOST_NAME --monmap $MONMAP --keyring $MON_KEYRING" "将mon map 和 mon keyring添加到mon守护进程失败"

execute_command "sudo systemctl start ceph-mon@$HOST_NAME" "启动mon服务失败"

execute_command "sudo systemctl enable ceph-mon@$HOST_NAME" "设置mon服务自启动失败"



script_name=$(basename "$0")
echo "当前脚本执行完成$script_name"
