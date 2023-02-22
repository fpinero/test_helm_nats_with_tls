# Deploy NATS with Helm

* Add nats repository
```
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm repo update
```
* Creating the namespace.
```
kubectl create namespace nats
```

* Creating the Load Balancer service. We need to deploy the LB first of all because we need to obtain an external IP for adding it to the corresponding jsons.
* load-balancer-svc.yaml:
````
apiVersion: v1
kind: Service
metadata:
  name: nats-lb
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-tcp-idle-timeout: "10"
spec:
  type: LoadBalancer
  externalTrafficPolicy: Local
  selector:
    app.kubernetes.io/instance: nats
    app.kubernetes.io/name: nats
  ports:
    - protocol: TCP
      port: 4222
      targetPort: 4222
      name: client
    - protocol: TCP
      port: 7422
      targetPort: 7422
      name: leafnodes
````
* Deploying the service.
````
kubectl apply -f load-balancer-svc.yaml -n nats
````
(We won't have endpoints launching the LB right now, because the service is unable to find the selectors, but at this moment, the only thing we want is an external IP).

* Creating the certificates <br/>
If anybody outside the organization needs to connect, it is recommended get certs from a public certificate authority.<br/>
We are going to generate de certificates using the tool cfssl https://github.com/cloudflare/cfssl#installation, a tool that makes your life easier compared to openssl, but if you feel more comfortable using openssl, feel free to use it instead of cfssl. 

* Generating the Root CA Certs
* ca-csr.json:
```
{
    "CN": "nats.io",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "OU": "nats.io"
        }
    ]
}

```
```
cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
```
* Set up the profiles for the Root CA, we will have 3 main profiles: one for the clients connecting, one for the servers, and another one for the full mesh routing connections between the servers.
* ca-config.json:
````
{
    "signing": {
        "default": {
            "expiry": "43800h"
        },
        "profiles": {
            "server": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ]
            },
            "client": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "client auth"
                ]
            },
            "route": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ]
            }
        }
    }
}

````
* Generating the peer certificates.
* server.json:
  * change the last line in the hosts array for the current IP of your Load Balancer, or even better, create a FQDN subdomain pointing to the IP of the LB and add it in hosts.
````
{
    "CN": "nats.io",
    "hosts": [
        "localhost",
        "*.nats-cluster.default.svc",
        "*.nats-cluster-mgmt.default.svc",
        "nats-cluster",
        "nats-cluster-mgmt",
        "nats-cluster.default.svc",
        "nats-cluster-mgmt.default.svc",
        "nats-cluster.default.svc.cluster.local",
        "nats-cluster-mgmt.default.svc.cluster.local",
        "*.nats-cluster.default.svc.cluster.local",
        "*.nats-cluster-mgmt.default.svc.cluster.local",
        "nats-cluster.default.svc.cluster.local",
        "*.nats.nats.svc.cluster.local",
        "20.101.205.253"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "OU": "Operator"
        }
    ]
}

````
````
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server server.json | cfssljson -bare server
````
* Generating the NATS server routes certs. Setting up TLS for the full mesh routes.
* route.json:
````
{
    "CN": "nats.io",
    "hosts": [
        "localhost",
        "*.nats-cluster.default.svc",
        "*.nats-cluster-mgmt.default.svc",
        "nats-cluster",
        "nats-cluster-mgmt",
        "nats-cluster.default.svc",
        "nats-cluster-mgmt.default.svc",
        "nats-cluster.default.svc.cluster.local",
        "nats-cluster-mgmt.default.svc.cluster.local",
        "*.nats-cluster.default.svc.cluster.local",
        "*.nats-cluster-mgmt.default.svc.cluster.local",
        "nats-cluster.default.svc.cluster.local",
        "*.nats.nats.svc.cluster.local",
        "20.101.205.253"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "OU": "Operator"
        }
    ]
}

````
* Generating the peer certificates.
````
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=route route.json | cfssljson -bare route
````
* Generating the certs for the clients.
* client.json:
````
{
    "CN": "nats.io",
    "hosts": [""],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "OU": "CNCF"
        }
    ]
}

````
````
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=client client.json | cfssljson -bare client
````
* Generating de auth secret
````
{
  "users": [
    { "username": "CN=nats.io,OU=ACME" },
    { "username": "CN=nats.io,OU=CNCF",
      "permissions": {
    "publish": ["hello.*"],
    "subscribe": ["hello.world"]
      }
    }
  ],
  "default_permissions": {
    "publish": ["SANDBOX.*"],
    "subscribe": ["PUBLIC.>"]
  }
}
````

* Creating the secrets.
````
kubectl create secret generic nats-server-tls-certs --from-file ca.pem --from-file route-key.pem --from-file route.pem --from-file server-key.pem --from-file server.pem -n nats
kubectl create secret generic nats-client-tls-certs --from-file ca.pem --from-file client-key.pem --from-file client.pem -n nats
kubectl create secret generic nats-tls-users --from-file=users.json -n nats
````

* create configmap for resolver
```
kubectl create configmap nats-resolver --from-file=resolver.conf=./resolver.conf -n nats
```

* Install NATS with helm setting it for HA and TLS
```
helm upgrade --install nats nats/nats --namespace nats --create-namespace --wait \
--set auth.resolver.type="memory" \
--set auth.resolver.configMap.name="nats-resolver" \
--set auth.resolver.configMap.key="resolver.conf" \
--set nats.jetstream.enabled=true \
--set nats.jetstream.domain="cloud" \
--set leafnodes.enabled=true \
--set leafnodes.port=7422 \
--set leafnodes.noAdvertise=true \
--set auth.enabled=true \
--set nats.externalAccess=true \
--set nats.advertise=false \
--set cluster.enabled=true \
--set cluster.replicas=3 \
--set cluster.noAdvertise=true \
--set nats.tls.allowNonTLS=false \
--set nats.tls.secret.name=nats-server-tls-certs \
--set nats.tls.cert="server.pem" \
--set nats.tls.key="server-key.pem" \
--set nats.tls.ca="ca.pem"
```
* Check if the Load Balancer was able to get the endpoints now that NATS has been deployed.
```
kubectl get endpoints -n nats
```
if not, force the update (this won't change the external IP if you don't delete the service).
```
kubectl apply -f load-balancer-svc.yaml -n nats
```
* Install the nsc tool following the instructions according to your O.S.

https://github.com/nats-io/nsc#install

# Setting up leaf nodes
* create operator (only once)
  * creates the operator and generates a signing key. Also initializes the SYS account and a sys user
```
nsc add operator --generate-signing-key --sys --name external
```
* Force to use signing keys for all accounts of this operator.
  * (Change the NATS' IP for the current one of your LB.)
```
nsc edit operator --require-signing-keys --account-jwt-server-url "nats://20.101.205.253:4222"
```
* create account (per tenant)
  * generate the account "TENANT_A"
```
nsc add account TENANT_A
```
  * generate a signing key for the account
```
nsc edit account TENANT_A --sk generate
```
* create user (per nats-user)
  * create the user 'user_tenant_a' in the account 'TENANT_A'
```
nsc add user --account TENANT_A user_tenant_a
```
* generate user credentials file (per nats-user)
```
nsc generate creds -n user_tenant_a > user_tenant_a.creds
```
* configure nats cli to use an account
  * (be careful with the IP, it has to be the one of your LB)
```
nats context save main-user \
  --server "nats://20.101.205.253:4222" \
  --nsc nsc://external/TENANT_A/user_tenant_a
```
* create a context that can be selected to connect with the nats cli. This context uses the external NATS broker and the created user early.
  * create resolver.conf (only once), Let's generate the resolver.conf file that is needed for the server to setup the JWT resolver
```
nsc generate config --nats-resolver --sys-account SYS > resolver.conf
```
* Allow user TENANT_A to create unlimited streams
```
nsc edit account --name TENANT_A --js-mem-storage -1 --js-disk-storage -1 --js-streams -1 --js-consumer -1
```
* Set the environment vars to validate us using TLS before push the account JWT to account JWT server
```
export NATS_CERT=/path/to/client.pem
export NATS_KEY=/path/to/client-key.pem
export NATS_CA=/path/to/ca.pem
```
* Now we can push the account JWT to the server that will update correctly our resolver.conf
```
nsc push -A
```
We are done!, we can do some basic tests running these nats commands:
```
nats sub test &
nats pub test hi
nc nats 4222
```
