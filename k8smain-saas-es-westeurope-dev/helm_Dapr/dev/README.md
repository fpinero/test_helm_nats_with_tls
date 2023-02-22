# Dapr Helm Chart

* Add the official Dapr Helm chart.

```
helm repo add dapr https://dapr.github.io/helm-charts/
```

```
helm repo update
```

* See which chart versions are available

```
helm search repo dapr --devel --versions
```

```
helm upgrade --install dapr dapr/dapr \
--version=1.8.4 \
--namespace dapr-system \
--create-namespace \
--wait
```

------

* To install in high availability mode use helm with these params:

```
helm upgrade --install dapr dapr/dapr \
--version=1.8.4 \
--namespace dapr-system \
--create-namespace \
--set global.ha.enabled=true \
--wait
```