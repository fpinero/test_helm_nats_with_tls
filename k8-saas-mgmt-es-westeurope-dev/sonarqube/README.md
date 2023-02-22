## Obsolete!! Use helm_sonarqube folder to deploy a more recent version of sonarqube and postgres ##
----

# sonarqube-kubernetes

-----
Create sonarqube namescpace
-----
    kubectl create namespace bz-sonarqube
-----

Encode USERNAME and PASSWORD of Postgres using following commands:
--------
    echo -n "this_is_a_fake_user_dev" | base64
    echo -n "this_is_a_fake_password_dev" | base64
Create the Secret using kubectl apply:
-------
    kubectl apply -f postgres-secrets.yml -n bz-sonarqube

Create PV and PVC for Postgres using yaml file:
-----
    kubectl apply -f postgres-storage.yaml -n bz-sonarqube

Deploying Postgres with kubectl apply:
-----------
    kubectl apply -f postgres-deployment.yaml -n bz-sonarqube
    kubectl apply -f postgres-service.yaml -n bz-sonarqube

Create PV and PVC for Sonarqube:
-------------
    kubectl apply -f sonar-pv-data.yml -n bz-sonarqube
    kubectl apply -f sonar-pv-extensions.yml -n bz-sonarqube
    kubectl apply -f sonar-pvc-data.yml -n bz-sonarqube
    kubectl apply -f sonar-pvc-extentions.yml -n bz-sonarqube
Create configmaps for URL which we use in Sonarqube:
-------
    kubectl apply -f sonar-configmap.yaml -n bz-sonarqube
Deploy Sonarqube:
-------------
    kubectl apply -f sonar-deployment.yml -n bz-sonarqube
    kubectl apply -f sonar-service.yml -n bz-sonarqube
Check secrets:
-------
    kubectl get secrets -n bz-sonarqube
    kubectl get configmaps -n bz-sonarqube
    kubectl get pv -n bz-sonarqube
    kubectl get pvc -n bz-sonarqube
    kubectl get deploy -n bz-sonarqube
    kubectl get pods -n bz-sonarqube
    kubectl get svc -n bz-sonarqube
---    
** Currently a LoadBalancer service is being used to access sonarqube, this has been done only to test the correct functioning of sonarqube.<br />
This service must be changed to an ngnix-ingress or an ingress and decide which internal Bizerba route will be used to access sonasqube from the pipelines to pass the tests to the applications during their continuous integration.
---
Default Credentials for Sonarqube:
-------
    UserName: admin
    PassWord: admin
    
Now we can cleanup by using below commands:
--------
    kubectl delete deploy postgres sonarqube -n bz-sonarqube
    kubectl delete svc postgres sonarqube -n bz-sonarqube
    kubectl delete pvc postgres-pv-claim sonar-data sonar-extensions -n bz-sonarqube
    kubectl delete pv postgres-pv-volume sonar-pv-data sonar-pv-extensions -n bz-sonarqube
    kubectl delete configmaps sonar-config -n bz-sonarqube
    kubectl delete secrets postgres-secrets -n bz-sonarqube
