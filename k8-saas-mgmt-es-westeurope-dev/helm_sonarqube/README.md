# sonarqube-kubernetes-helm

-----
Create sonarqube namespace
-----
    kubectl create namespace bz-sonarqube
-----

Install sonarqube and postgres using following commands:
--------
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update
    helm install --namespace bz-sonarqube sonarqube151 bitnami/sonarqube --version 1.5.1
----

SonarQube site can be accessed through the following DNS name from within the cluster:
-------
    sonarqube151.bz-sonarqube.svc.cluster.local (port 80)

To access your SonarQube site from outside the cluster follow the steps below:
-----
    1. Get the SonarQube URL by running these commands:

    NOTE: It may take a few minutes for the LoadBalancer IP to be available.
        Watch the status with: 'kubectl get svc --namespace bz-sonarqube -w sonarqube151'

    export SERVICE_IP=$(kubectl get svc --namespace bz-sonarqube sonarqube151 --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
    echo "SonarQube URL: http://$SERVICE_IP/"

    2. Open a browser and access SonarQube using the obtained URL.

    3. Login with the following credentials below:

    echo Username: user
    echo Password: $(kubectl get secret --namespace bz-sonarqube sonarqube151 -o jsonpath="{.data.sonarqube-password}" | base64 -d)
-----

** Currently, a LoadBalancer service is being used to access sonarqube, this has been done only to test the correct functioning of sonarqube.<br />
This service must be changed to an ngnix-ingress or an ingress and decide which internal Bizerba route will be used to access sonarqube from the pipelines to pass the tests to the applications during their continuous integration.
---
