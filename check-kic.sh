#!/bin/bash

echo "=== Kong Ingress Controller 安装状态检查 ==="
echo

echo "1. 检查 Helm 发布状态:"
helm list -n kong
echo

echo "2. 检查 Kong 命名空间中的 Pods:"
kubectl get pods -n kong
echo

echo "3. 检查 Kong 服务:"
kubectl get svc -n kong
echo

echo "4. 检查 Kong Ingress Controller 日志 (最后10行):"
kubectl logs -n kong -l app.kubernetes.io/name=ingress --tail=10
echo

echo "5. 检查 IngressClass:"
kubectl get ingressclass
echo

echo "=== 如果以上都正常，可以部署测试应用 ==="
echo "运行以下命令部署测试应用:"
echo "kubectl apply -f test-app.yaml"
echo
echo "然后检查 Ingress 资源:"
echo "kubectl get ingress"
echo
echo "测试访问 (需要配置 hosts 文件):"
echo "curl -H 'Host: docker.local' http://localhost"
