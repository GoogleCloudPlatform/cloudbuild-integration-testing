# Integration Testing on GCB
This is a demo showing how to execute multi-container integration tests as part of a [Google Cloud Build](https://cloud.google.com/cloud-build/) invocation

## Method 1: docker-compose
Prerequisite:
Build the [docker-compose community builder](https://github.com/GoogleCloudPlatform/cloud-builders-community/tree/master/docker-compose) and push to [Google Container Registry](https://cloud.google.com/container-registry/) in your GCP project

Run command:
`gcloud builds submit --config=cloudbuild.compose.yaml .`

## Method 2: deploy to existing kubernetes cluster
Prerequisites:

1. A running kubernetes cluster (this example uses GKE)
  - `gcloud container clusters create staging --zone us-central1-c` 
2. Cloud Build service account must have role: "Kubernetes Engine Developer"
  - TODO: add service account gcloud command
  Run command:
  `gcloud builds submit --config=cloudbuild.gke.yaml .`

## Method 3: deploy to self-destructing VM

### to do things locally:
```
# run terraform to create a self-destructing VM w/ microk8s
terraform apply -var="project-name=$(gcloud config get-value project 2> /dev/null)" -var="instance-name=test-$(date +%s)" -auto-approve

# get the IP from terraform
echo $(terraform output ip) > .tmp.microk8s_ip

# patch the IP into the kubectl config
# (backup flag is passed for macOS compatibility)
# TODO: use a better regex so this can work repeatedly instead of just once
sed -i.sed-bak "s/CLUSTER_IP/$(< .tmp.microk8s_ip)/" kubeconfig.microk8s

# kubectl can now deploy to microk8s
kubectl apply -f ./k8s --kubeconfig=kubeconfig.microk8s

# see services
kubectl get services --kubeconfig=kubeconfig.microk8s
```

### to do things in Cloud Build:
(prerequisite: terraform builder is built and pushed to GCR in project)
```
gcloud builds submit --config=cloudbuild.vm.yaml .
```



This is not an official Google product.
