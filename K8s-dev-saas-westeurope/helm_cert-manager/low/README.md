# Install Kubernetes Cert-Manager and Configure Let’s Encrypt

* Add the necessary helm chart
-----
`helm repo add jetstack https://charts.jetstack.io` <br >
`helm repo update`
-----

* Create the namespace and install the Cert-Manager helm
-----
`kubectl create ns cert-manager` <br >
`helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.9.1 --set installCRDs=true`
-----

* Adding the Kubectl Plugin
Cert-Manager has a Kubectl plugin which simplifies some common management tasks.<br > It also lets you check whether Cert-Manager is up and ready to serve requests.
<br ><br >
* (Linux)
-----
`curl -L -o kubectl-cert-manager.tar.gz https://github.com/jetstack/cert-manager/releases/latest/download/kubectl-cert_manager-linux-amd64.tar.gz` <br >
`tar xzf kubectl-cert-manager.tar.gz` <br >
`sudo mv kubectl-cert_manager /usr/local/bin`
-----
* (Mac)
-----
`curl -L -o kubectl-cert-manager.tar.gz https://github.com/cert-manager/cert-manager/releases/download/v1.9.1/kubectl-cert_manager-darwin-amd64.tar.gz` <br >
`tar xzf kubectl-cert-manager.tar.gz` <br >
`sudo mv kubectl-cert_manager /usr/local/bin`
-----
* (Windows)
-----
`curl -L -o kubectl-cert-manager.tar.gz https://github.com/cert-manager/cert-manager/releases/download/v1.9.1/kubectl-cert_manager-windows-amd64.zip` <br >
`unzip kubectl-cert-manager.tar.gz` <br >
`copy "kubectl-cert_manager C:\Program Files"`
-----

* Use the plugin to check your Cert-Manager installation is working:
kubectl cert-manager check api

`kubectl cert-manager check api`

* Creating a Certificate Issuer
-----
* issuer.yaml
````
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: example@example.com
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
      - http01:
          ingress:
            class: nginx
````

(With this yaml we have created a ClusterIssuer as these are available to all resources in your cluster, irrespective of namespace. A standard Issuer is a namespaced resource which can only supply certificates within its own namespace.)

-----
`kubectl create -f issuer.yml`

-------
* Update your Ingress

The presence of the cert-manager.io/cluster-issuer annotation in the Ingress resource will be detected by Cert-Manager. It will use the letsencrypt-staging cluster issuer created earlier to acquire a certificate covering the hostnames defined in the Ingress’ tls.hosts field

````
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-staging
  .
  .
  .
````
# Using Let’s Encrypt in Production

Once you’ve successfully acquired a staging certificate, you can migrate to the Let’s Encrypt production servers. Staging certificates are valid but not trusted by browsers so you must get a production replacement before putting your site live.

It’s best to add a separate cluster issuer for the production server. You can then reference the appropriate issuer in each of your Ingress resources, depending on whether they’re production-ready.

Copy the issuer configuration shown above and change the name fields to letsencrypt-production. Next, replace the server URL with the value shown below:

-----
`https://acme-v02.api.letsencrypt.org/directory`

* Create the new issuer in your cluster:

`kubectl create -f issuer-production.yml`

* update your Ingress resource to request a production certificate by changing the value of the cert-manager.io/cluster-issuer annotation to letsencrypt-production (or the name you assigned to your own production issuer). Use kubectl to apply the change:

`kubectl apply -f my-ingress.yaml`

-----
