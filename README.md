# Kong Ingress Controller

这是一个用于在 macOS Docker Desktop Kubernetes 环境中安装和测试 Kong Ingress Controller (KIC) 的配置文件集合。

## 前置要求

- macOS 系统
- Docker Desktop 已安装并启用 Kubernetes
- kubectl 命令行工具已安装

```bash
helm install kong kong/ingress -n kong --create-namespace
```

## 验证安装

运行检查脚本验证 KIC 安装状态：
```bash
./check-kic.sh
```

或手动检查：
```bash
# 检查 Helm 发布
helm list -n kong

# 检查 Kong pods
kubectl get pods -n kong

# 检查 Kong 服务
kubectl get svc -n kong
```

## 测试服务

部署测试应用：
```bash
kubectl apply -f test-app.yaml
```

检查 Ingress 资源：
```bash
kubectl get ingress
```

测试访问（需要先配置 /etc/hosts）：
```bash
# 添加到 /etc/hosts: 127.0.0.1 docker.local
curl -H 'Host: docker.local' http://localhost
```

## JWT 认证配置

### 部署 JWT 认证

运行部署脚本：
```bash
chmod +x deploy-jwt.sh
./deploy-jwt.sh
```

或手动部署：
```bash
# 部署 JWT 插件和凭证配置
kubectl apply -f jwt-auth.yaml

# 部署受保护的测试应用
kubectl apply -f jwt-protected-app.yaml
```

### 测试 JWT 认证

运行测试脚本：
```bash
# 重新部署并测试
chmod +x simple-jwt-test.sh
./simple-jwt-test.sh

# 运行 PHP 测试脚本
php test-jwt.php
```

手动测试：
```bash
# 配置 hosts 文件: 127.0.0.1 protected.local

# 无 token 访问 (应该返回 401)
curl -H 'Host: protected.local' http://localhost/

# 使用 JWT token 访问
# 先运行 test-jwt.py 获取 token，然后:
curl -H 'Host: protected.local' -H 'Authorization: Bearer YOUR_TOKEN' http://localhost/
```

### JWT 配置说明

- **发行者 (iss)**: `production-issuer`
- **算法**: `HS256`
- **密钥**: `production-secret-key-2025` (生产环境请更换)
- **支持的传递方式**: Authorization header
- **验证字段**: `nbf` (not before) 和 `exp` (expiration)

## JWT 头部提取功能

### 功能说明

本项目实现了一个 Kong Lua 插件，能够自动解析 JWT payload 并将指定字段添加到请求头部，方便后端服务获取用户信息。

**提取的字段**:
- `sub` → `X-JWT-Sub`
- `user_id` → `X-JWT-User-Id`
- `roles` → `X-JWT-Roles`

**排除的字段**: `iss`, `nbf`, `exp`

### 部署方法

插件已经集成在 JWT 认证配置中，无需额外部署：

```bash
# JWT 头部提取插件已包含在 jwt-protected-app.yaml 中
kubectl apply -f jwt-protected-app.yaml
```

### 测试 JWT 头部提取

运行测试脚本验证功能：
```bash
chmod +x test-jwt-headers.sh
./test-jwt-headers.sh
```

或手动测试：
```bash
# 生成 JWT token
php test-jwt.php

# 测试并查看提取的头部
curl -s -H 'Host: protected.local' \
     -H "Authorization: Bearer $(php test-jwt.php)" \
     http://localhost/ | jq '.request.headers' | grep -E "(x-jwt-|X-JWT-)"
```

**预期输出**:
```json
{
  "x-jwt-sub": "8241",
  "x-jwt-user-id": "8241",
  "x-jwt-roles": "[\"user\"]"
}
```

### 技术实现

- **插件类型**: Kong pre-function 插件
- **执行时机**: JWT 认证成功后
- **解析方式**: 手动正则表达式解析（避免 Kong 沙箱限制）
- **配置文件**: `jwt-headers-final.yaml`

### 插件顺序

```yaml
annotations:
  konghq.com/plugins: jwt-auth,jwt-headers-final
```

确保 JWT 认证插件先执行，头部提取插件后执行。


## Helpers

临时运行 curl 测试：

```bash
kubectl run test-curl --image=curlimages/curl --rm -it --restart=Never -- sh
```