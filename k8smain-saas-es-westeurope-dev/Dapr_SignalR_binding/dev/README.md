# Dapr Azure SignalR binding

* To setup Azure SignalR binding create a component of type bindings.azure.signalr :
`````
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: daprlinksignalr
spec:
  type: bindings.azure.signalr
  version: v1
  metadata:
  - name: dapr-sinalr-connectionstring
    secretKeyRef:
      name: urlConnString
      key: keyConnString
`````

* Store the AccesKey and EndPoint of SignalR in a kubernetes Secret :
````
apiVersion: v1
kind: Secret
metadata:
  name: dapr-sinalr-connectionstring
type: Opaque
data:
  keyConnString: QWNjZXNzS2V5PStCRW1hM25HamlHSGVkejIzZTM5a2MyRjY3MXRXdTcxUmovbXgreUJ4cWc9
  urlConnString: RW5kcG9pbnQ9aHR0cHM6Ly9iaXplcmJhZGV2LnNlcnZpY2Uuc2lnbmFsci5uZXQ=
````

* Create the Secret in the desired namespace:
````
kubectl apply -f Secret_SignalR_Connection_String.yaml -n dev
````

* And deploy de binding Component in the desired namespace:
````
kubectl apply -f DaprComponent.yaml -n dev
````