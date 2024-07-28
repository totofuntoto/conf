git -c core.sshCommand="ssh -o StrictHostKeyChecking=no"#!/bin/bash

# 执行失败则退出
set -e
trap 'echo "执行失败:$BASH_COMMAND"' ERR

# 都需要更新apt 并安装 nginx，git 以及 xrayr
apt -y update && apt -y install nginx git && bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)

# 配置git global参数
git config --global user.name "xxx" && git config --global user.email "hjklsad@sldjfal.com"

# 设置仓库目录
read -p "输入仓库目录 :" REPDIR

# 克隆远程仓库
cd /root
git -c core.sshCommand="ssh -o StrictHostKeyChecking=no" clone git@github.com:totofuntoto/${REPDIR}.git

# 拷贝对应配置到对应目录
cd / && tar -xzvf /root/${REPDIR}/acme.tar.gz && cd /root/${REPDIR} && cp -r XrayR/ /etc && cp -r ssl/ /etc/nginx/ && cp nginx.conf /etc/nginx/ && cp default /etc/nginx/sites-available/

# 添加cron任务，在acme成功renew后推送到远程仓库
(crontab -l ; echo "0 4 * * * '/root/.acme.sh'/acme.sh --cron --home '/root/.acme.sh' --renew-hook 'cd /root/${REPDIR} &&git pull && tar -czvf acme.tar.gz /root/.acme.sh && cp -r /etc/XrayR . && cp -r /etc/nginx/ssl .&& cp /etc/nginx/nginx.conf . && cp /etc/nginx/sites-available/default . && git add . && git commit -m \"acme renewed\" && git push origin master && nginx -s reload' > /dev/null " ) | crontab -
