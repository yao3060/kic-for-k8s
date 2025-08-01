#!/bin/bash

echo "=== Kong Ingress Controller 测试脚本 ==="
echo

echo "1. 检查测试应用 Pods:"
kubectl get pods -l app=echo-server
echo

echo "2. 检查 Ingress 资源:"
kubectl get ingress echo-ingress -o wide
echo

echo "3. 检查 Kong 代理服务端口:"
kubectl get svc kong-gateway-proxy -n kong
echo

echo "4. 测试访问 (通过 Kong 代理):"
echo "正在测试 http://localhost/..."
curl -H 'Host: docker.local' http://localhost/ -v
echo
echo

echo "5. 如果上面的测试失败，尝试使用 NodePort:"
NODEPORT=$(kubectl get svc kong-gateway-proxy -n kong -o jsonpath='{.spec.ports[0].nodePort}')
echo "NodePort: $NODEPORT"
echo "测试命令: curl -H 'Host: docker.local' http://localhost:$NODEPORT/"
curl -H 'Host: docker.local' http://localhost:$NODEPORT/ -v
echo

echo "=== 测试完成 ==="
