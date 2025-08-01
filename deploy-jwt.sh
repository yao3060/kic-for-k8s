#!/bin/bash

echo "=== Kong JWT 认证部署脚本 ==="
echo

echo "1. 部署 JWT 认证配置..."
kubectl apply -f jwt-auth.yaml
kubectl apply -f jwt-headers-final.yaml
echo

echo "2. 等待配置生效..."
sleep 5
echo

echo "3. 部署受保护的测试应用..."
kubectl apply -f jwt-protected-app.yaml
echo

echo "4. 等待应用启动..."
sleep 10
echo

echo "5. 检查部署状态:"
echo "检查 KongPlugin:"
kubectl get kongplugin test-jwt-auth
echo

echo "检查 KongConsumer:"
kubectl get kongconsumer test-jwt-user
echo

echo "检查 KongCredential:"
kubectl get secret test-jwt-credential
echo

echo "检查受保护应用的 Pod:"
kubectl get pods -l app=protected-app
echo

echo "检查受保护应用的 Ingress:"
kubectl get ingress protected-ingress
echo

echo "=== 部署完成 ==="
echo
echo "现在可以测试 JWT 认证:"
echo "1. 运行测试脚本: php test-jwt.php"
echo
echo "或者手动测试:"
echo "# 无 token 访问 (应该返回 401):"
echo "curl -H 'Host: protected.local' http://localhost/"
echo
echo "# 使用 JWT token 访问:"
echo "# 先运行 php test-jwt.php 获取 token，然后:"
echo "# curl -H 'Host: protected.local' -H 'Authorization: Bearer YOUR_TOKEN' http://localhost/"
