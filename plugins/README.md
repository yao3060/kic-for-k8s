# install kong plugin 

## 📦 一、自定义插件准备与 ConfigMap 创建
假设你本地已有插件目录 add-custom-header/，包含 handler.lua 和 schema.lua：

```bash
kubectl create configmap kong-plugin-addheader \
--from-file=add-custom-header/handler.lua \
--from-file=add-custom-header/schema.lua -n kong
```
该 ConfigMap 会把插件目录打包上传至 Kubernetes。


## 🛠 二、编写 values.yaml 并启用插件挂载
在你的 Helm chart 安装里加入以下内容，告知 Kong 将该 ConfigMap 挂载为插件：

```yaml
gateway:
  plugins:
    configMaps:
      - name: kong-plugin-addheader
        pluginName: add-custom-header

```
这段配置将使 Helm 在部署时：

将 ConfigMap 挂载至 /opt/kong/plugins/add-custom-header

自动设置环境变量 KONG_PLUGINS=bundled,add-custom-header

配置 KONG_LUA_PACKAGE_PATH 包含挂载路径，以便 Kong 加载插件

## 🚀 三、使用 Helm 升级或安装 Kong
运行以下命令，应用你的 values.yaml：

```bash
helm upgrade kong kong/ingress -n kong --create-namespace --values values.yaml
```
等待 Pod 重启完成后（可使用 kubectl get pods -n kong 查看状态），你的插件环境就绪。

## 四、启用插件并验证 Admission Webhook
插件环境就绪后，即可创建你的 jwt-add-custom-header.yaml（KongPlugin CRD）：
```yaml
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: add-custom-header
  namespace: default
plugin: add-custom-header
config:
  header_name: "X-Custom-Header"
  header_value: "HelloWorld"
```

然后在 Service 或 Ingress 上添加 annotation 启用插件：

```yaml
metadata:
  annotations:
    konghq.com/plugins: add-custom-header

```

此时 Admission Webhook 校验应不会再报错，因为插件已在 KONG_PLUGINS 中启用。