#!/bin/bash

source ./deploy-base.sh


#随便找一台正在运行的mon节点上修改ceph.conf，增加相应的mon initial members与mon host，不再赘述。然后同步到所有节点。
#只要是节点的/etc/ceph 目录下存在ceph.conf 和 ceph.client.admin.keyring 即可.


#确认本机IP
HOST_NAME=`hostname -s`
MON_PORT=6789
MON_DIR=/var/lib/ceph/mon/$CLUSTER_NAME-$HOST_NAME
MON_KEYRING=/tmp/ceph.mon.keyring
MONMAP=/tmp/monmap



#确认变量信息
echo "HOST_NAME $HOST_NAME"
echo "NODE_IP $NODE_IP"
echo "MON_PORT $MON_PORT"
echo "MON_DIR $MON_DIR"
echo "MON_KEYRING $MON_KEYRING"
echo "MONMAP $MONMAP"
echo -e "${RED}执行一次赋权脚本${RESET}"



confirm_execution "确认以上变量值是否正确？y/n" "用户选择了否。"

if [ $? -eq 0 ]; then
    # 继续执行需要执行的操作
	echo "continue..."
else
    # 执行其他操作或退出脚本
    echo "退出脚本..."
    exit 1
fi

#获取集群的mon.keyring密钥并保存到文件
execute_command "sudo ceph auth get mon. -o $MON_KEYRING" "获取集群的mon.keyring密钥并保存到文件失败"
execute_command "sudo chown ceph:ceph $MON_KEYRING" "设置$MON_KEYRING所有者和所属组失败"
#获取集群的mon map 并保存到文件
execute_command "sudo ceph mon getmap -o $MONMAP" "获取集群的mon map 并保存到文件失败"
execute_command "sudo chown ceph:ceph $MONMAP" "设置$MONMAP 所有者和所属组失败"

#创建mon默认数据目录
create_folder $MON_DIR
execute_command "sudo chown -R ceph:ceph $MON_DIR" "设置密钥$MON_DIR 所有者和所属组失败"

#创建一个Ceph Monitor
execute_command "sudo ceph-mon -i $HOST_NAME --mkfs --monmap $MONMAP --keyring $MON_KEYRING" "创建Ceph Monitor失败"
execute_command "sudo chown -R ceph:ceph $MON_DIR" "设置$MON_DIR 所有者和所属组失败"
execute_command "sudo setfacl -Rm u:$user:rwx $MON_DIR" "向目录$MON_DIR 添加用户$user 的访问控制权限失败"

#启动mon服务
execute_command "sudo ceph-mon -i $HOST_NAME --setuser ceph --setgroup ceph --public-addr $NODE_IP:$MON_PORT" "启动mon服务失败"

execute_command "sudo systemctl enable ceph-mon@$HOST_NAME" "设置mon服务自启动失败"

execute_command "sudo ceph mon enable-msgr2" "启用msgr2协议失败"

script_name=$(basename "$0")
echo "当前脚本执行完成$script_name"
