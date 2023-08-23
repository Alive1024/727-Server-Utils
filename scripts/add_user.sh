#!/bin/bash

username=''
project_id=''
port=''

# 检查是否传递了第一个参数，并将其赋值给变量 username
if [ -n "$1" ]; then
  username="$1"
else
  echo "请在命令行中提供用户名作为第一个参数。"
  exit 1
fi

# 检查是否传递了第一个参数，并将其赋值给变量 username
if [ -n "$2" ]; then
  port="$2"
else
  echo "请在命令行中提供ssh端口作为第二个参数。"
  exit 1
fi

find_next_project_id() {
  result=$(xfs_quota -x -c "report" | grep "#" | awk '{print $1}')

  # 使用 grep 和 awk 查找 # 后的最大 project id
  max_num=$(echo "$result" | grep -o '#[0-9]*' | awk -F'#' '{print $2}' | sort -nr | head -1)

  # 将最大数字加一返回，作为下一个可用的 project id
  echo $((max_num + 1))
}

project_id=$(find_next_project_id)

# 创建 docker 卷
docker volume create "$username-vol"

# > /dev/null 2>&1
# 创建配额
echo "$project_id:/data/docker/volumes/$username-vol" >> /etc/projects
echo "$username-quota-#$project_id:$project_id" >> /etc/projid
xfs_quota -x -c "project -s $username-quota-#$project_id"
xfs_quota -x -c "limit -p bsoft=800G bhard=800G $username-quota-#$project_id"

docker run -itd --privileged \
--gpus all \
--restart=unless-stopped \
--ipc=host \
-v $username-vol:/home \
-p $port:22 -p $((port+1))-$((port+4)):$((port+1))-$((port+4)) \
--name $username \
alive1024/727-base:latest
