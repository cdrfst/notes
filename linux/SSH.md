``` shell
# 如下命令可不必输入多次回车
ssh-keygen -f ~/.ssh/id_rsa -P "" > /dev/null 2>&1
```
## 免密登陆

### 公钥分发脚本
``` shell
#!/bin/bash

rm -rf ~/.ssh/id_rsa*
ssh-keygen -f ~/.ssh/id_rsa -P "" > /dev/null 2>&1
SSH_Pass=123456
Key_Path=~/.ssh/id_rsa.pub
for ip in ecm-12 ecm-13
do
        sshpass -p$SSH_Pass ssh-copy-id -i $Key_path "-o StrictHostKeyChecking=no" $ip
done

# 非交互式分发公钥需要用sshpass指定SSH密码，通过-o StrictHostKeyChecking=no 路过SSH连接确认信息
```
