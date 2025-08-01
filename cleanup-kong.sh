#!/bin/bash

echo "=== Kong 资源清理脚本 ==="
echo "此脚本将删除所有 Kong 相关的资源"
echo

# 确认操作
read -p "确定要删除所有 Kong 资源吗？(y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "操作已取消"
    exit 1
fi

echo
echo "开始清理 Kong 资源..."
echo

# 1. 删除测试应用资源
echo "1. 删除测试应用资源..."
kubectl delete -f test-app.yaml --ignore-not-found=true
kubectl delete -f jwt-protected-app.yaml --ignore-not-found=true
echo "✓ 测试应用资源已删除"
echo

# 2. 删除 JWT 认证配置
echo "2. 删除 JWT 认证配置..."
kubectl delete -f jwt-auth.yaml --ignore-not-found=true
echo "✓ JWT 认证配置已删除"
echo

# 3. 删除 Kong 插件和消费者
echo "3. 删除 Kong 插件和消费者..."
kubectl delete kongplugin jwt-auth --ignore-not-found=true
kubectl delete kongconsumer jwt-user --ignore-not-found=true
kubectl delete secret jwt-credential --ignore-not-found=true
echo "✓ Kong 插件和消费者已删除"
echo

# 4. 删除 Ingress 资源
echo "4. 删除 Ingress 资源..."
kubectl delete ingress echo-ingress --ignore-not-found=true
kubectl delete ingress protected-ingress --ignore-not-found=true
echo "✓ Ingress 资源已删除"
echo

# 5. 删除服务和部署
echo "5. 删除服务和部署..."
kubectl delete service echo-service --ignore-not-found=true
kubectl delete service protected-service --ignore-not-found=true
kubectl delete deployment echo-server --ignore-not-found=true
kubectl delete deployment protected-app --ignore-not-found=true
echo "✓ 服务和部署已删除"
echo

# 6. 删除 Kong 命名空间中的所有资源
echo "6. 清理 Kong 命名空间..."
kubectl delete all --all -n kong --ignore-not-found=true
kubectl delete configmap --all -n kong --ignore-not-found=true
kubectl delete secret --all -n kong --ignore-not-found=true
kubectl delete serviceaccount --all -n kong --ignore-not-found=true
kubectl delete rolebinding --all -n kong --ignore-not-found=true
kubectl delete role --all -n kong --ignore-not-found=true
echo "✓ Kong 命名空间资源已清理"
echo

# 7. 删除 Kong IngressClass
echo "7. 删除 Kong IngressClass..."
kubectl delete ingressclass kong --ignore-not-found=true
echo "✓ Kong IngressClass 已删除"
echo

# 8. 卸载 Helm 发布的 Kong
echo "8. 卸载 Helm 发布的 Kong..."
helm uninstall kong -n kong --ignore-not-found=true
echo "✓ Kong Helm 发布已卸载"
echo

# 9. 删除 Kong 命名空间
echo "9. 删除 Kong 命名空间..."
kubectl delete namespace kong --ignore-not-found=true
echo "✓ Kong 命名空间已删除"
echo

# 10. 清理可能残留的资源
echo "10. 清理可能残留的资源..."
kubectl delete kongplugin --all --ignore-not-found=true
kubectl delete kongconsumer --all --ignore-not-found=true
kubectl delete kongingress --all --ignore-not-found=true
kubectl delete kongclusterplugin --all --ignore-not-found=true
kubectl delete kongconsumergroup --all --ignore-not-found=true
kubectl delete kongcustomentity --all --ignore-not-found=true
kubectl delete konglicense --all --ignore-not-found=true
kubectl delete kongupstreampolicy --all --ignore-not-found=true
kubectl delete kongvault --all --ignore-not-found=true
kubectl delete tcpingress --all --ignore-not-found=true
kubectl delete udpingress --all --ignore-not-found=true
echo "✓ 残留资源已清理"
echo

echo "=== 清理完成 ==="
echo
echo "验证清理结果:"
echo "1. 检查 Kong 命名空间:"
kubectl get namespace kong --ignore-not-found=true
echo
echo "2. 检查 Helm 发布:"
helm list -n kong
echo
echo "3. 检查 Ingress 资源:"
kubectl get ingress --all-namespaces
echo
echo "4. 检查 Kong 相关资源:"
kubectl get kongplugin --all-namespaces --ignore-not-found=true
kubectl get kongconsumer --all-namespaces --ignore-not-found=true
kubectl get kongclusterplugin --all-namespaces --ignore-not-found=true
echo
echo "所有 Kong 资源已清理完毕！"
echo "现在可以重新安装 Kong Ingress Controller:"
echo "helm install kong kong/ingress -n kong --create-namespace" 