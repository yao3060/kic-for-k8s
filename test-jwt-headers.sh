#!/bin/bash

echo "=== 测试 JWT 头部提取功能 ==="

# 生成 JWT token
echo "1. 生成 JWT token..."
php test-jwt.php > /tmp/jwt_token.txt
JWT_TOKEN=$(cat /tmp/jwt_token.txt)
echo "Token: $JWT_TOKEN"
echo

# 测试带 JWT token 的请求
echo "2. 测试带 JWT token 的请求..."
echo "检查响应中是否包含提取的 JWT 头部..."
echo

curl -s -H 'Host: protected.local' \
     -H "Authorization: Bearer $JWT_TOKEN" \
     http://localhost/ | jq '.request.headers' | grep -E "(x-jwt-|X-JWT-)"

echo
echo "=== 完整响应头部 ==="
curl -s -H 'Host: protected.local' \
     -H "Authorization: Bearer $JWT_TOKEN" \
     http://localhost/ | jq '.request.headers'

echo
echo "=== 测试完成 ==="
echo "应该看到以下新增的头部："
echo "- X-JWT-Sub: 8241"
echo "- X-JWT-Iat: [timestamp]"
echo "- X-JWT-User-Id: 8241"
echo "- X-JWT-Roles: [\"user\"]"
