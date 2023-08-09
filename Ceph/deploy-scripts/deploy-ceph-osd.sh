#!/bin/bash

source ./deploy-base.sh

lsblk
echo "请输入设备名称:"
read device

if [ -z "$device" ]; then
    echo "设备不能为空！程序退出。"
    exit 1
fi
echo "设备：$device"

execute_command "sudo ceph-volume lvm create --data $device" "添加osd失败"

script_name=$(basename "$0")
echo "当前脚本执行完成$script_name"
