# Nacks Accounts Streams and subjects

* Install the JetStream CRDs:
```
kubectl apply -f https://github.com/nats-io/nack/releases/latest/download/crds.yml -n nats
```

* Install Nacks with helm:
```
helm install nack nats/nack --namespace nats --create-namespace --wait --set jetstream.nats.url=nats://nats:4222  
```

