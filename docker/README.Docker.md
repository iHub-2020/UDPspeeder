# UDPspeeder Docker 部署指南

## 快速开始

### 1. 服务端部署

```bash
# 创建配置文件
cp server.env .env
vim .env  # 修改配置

# 创建持久化目录
mkdir -p config logs

# 启动服务
docker-compose -f docker-compose-server.yml up -d

# 查看日志
docker-compose -f docker-compose-server.yml logs -f

2. 客户端部署
bash
# 创建配置文件
cp client.env .env
vim .env  # 修改 REMOTE_ADDR 为服务端IP

# 创建持久化目录
mkdir -p config logs

# 启动服务
docker-compose -f docker-compose-client.yml up -d

# 查看日志
docker-compose -f docker-compose-client.yml logs -f
```
### 参数说明
### 核心参数
FEC_PARAMS: FEC参数，格式 x:y，每x个包发送y个冗余包
PASSWORD: 加密密码，两端必须一致
WORK_MODE: 0=省流量，1=低延迟
### 游戏推荐参数
```bash
# 低丢包率网络 (<5%)
FEC_PARAMS=20:10
WORK_MODE=0

# 中等丢包率 (5-10%)
FEC_PARAMS=10:10
WORK_MODE=0
INTERVAL=10

# 高丢包率 (>10%)
FEC_PARAMS=5:5
WORK_MODE=0
INTERVAL=20
```
### 健康检查
容器启动后30秒开始健康检查：

```bash
docker ps  # 查看容器状态
```
### 故障排查
```bash
# 查看实时日志
docker logs -f udpspeeder-server

# 进入容器
docker exec -it udpspeeder-server /bin/bash

# 检查进程
docker exec udpspeeder-server pgrep speederv2
```

## 🚀 部署命令

```bash
# 服务端
docker-compose -f docker-compose-server.yml --env-file server.env up -d

# 客户端
docker-compose -f docker-compose-client.yml --env-file client.env up -d
```
