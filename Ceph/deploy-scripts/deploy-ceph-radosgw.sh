#!/bin/bash

source ./deploy-base.sh

#确认本机IP
HOST_NAME=`hostname -s`
RADOSGW_KEYRING=/etc/ceph/ceph.client.radosgw.keyring
RADOSGW_LOG_DIR=/var/log/radosgw


#检查文件是否已存在,如果已存在则大概率会报错：“Error EEXIST: entity client.rgw.$HOST_NAME exists but key does not match” 
#需要执行此命令解决：sudo ceph auth del client.rgw.`hostname -s`
check_exist $RADOSGW_KEYRING


#确认变量信息
echo "确认已经修改了ceph.conf !!!,否则RGW服务无法启动"
echo "HOST_NAME $HOST_NAME"
echo "RADOSGW_KEYRING $RADOSGW_KEYRING"
echo "RADOSGW_LOG_DIR $RADOSGW_LOG_DIR"
echo "ADMIN_KEYRING $ADMIN_KEYRING"


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
execute_command "sudo ceph-authtool --create-keyring $RADOSGW_KEYRING" "生成radosgw密钥失败"
execute_command "sudo chown ceph:ceph $RADOSGW_KEYRING" "设置密钥$RADOSGW_KEYRING 所有者和所属组失败"


execute_command "sudo ceph-authtool $RADOSGW_KEYRING -n client.rgw.$HOST_NAME --gen-key" "添加机器密钥失败"

execute_command "sudo ceph-authtool -n client.rgw.$HOST_NAME --cap osd 'allow rwx' --cap mon 'allow rwx' $RADOSGW_KEYRING" "添加访问权限失败"

#执行该命令后，Ceph集群将使用RGW密钥环中的密钥为client.rgw.$HOST_NAME添加身份验证权限。
execute_command "sudo ceph -k $ADMIN_KEYRING auth add client.rgw.$HOST_NAME -i $RADOSGW_KEYRING" "将$RADOSGW_KEYRING 导入到集群失败"

execute_command "sudo mkdir $RADOSGW_LOG_DIR" "创建radosgw log文件夹失败"

execute_command "sudo chown -R ceph:ceph $RADOSGW_LOG_DIR" "创建radosgw log文件夹失败"

execute_command "sudo systemctl start ceph-radosgw@rgw.$HOST_NAME" "启动radosgw服务失败"
execute_command "sudo systemctl enable ceph-radosgw@rgw.$HOST_NAME" "设置自启动radosgw服务失败"

script_name=$(basename "$0")
echo "当前脚本执行完成$script_name"
echo "如果当前RGW服务正常，端口无法访问可尝试重启机器解决!"
