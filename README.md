# Integration Testing on GCB
This is a demo showing how to execute multi-container integration tests as part of a [Google Cloud Build](https://cloud.google.com/cloud-build/) invocation

## Method 1: docker-compose
Prerequisite:
Build the [docker-compose community builder](https://github.com/GoogleCloudPlatform/cloud-builders-community/tree/master/docker-compose) and push to [Google Container Registry](https://cloud.google.com/container-registry/) in your GCP project

Run command:
`gcloud builds submit --config=compose.cloudbuild.yaml .`

## Method 2: deploy to existing kubernetes cluster [WIP]
Prerequisites:

0. A running kubernetes cluster (this example uses GKE)
- `gcloud container clusters create staging --zone us-west1-a` 
0. Cloud Build service account must have role: "Kubernetes Engine Developer"
- TODO: add service account gcloud command
Run command:
`gcloud builds submit --config=gke.cloudbuild.yaml .`

## Method 3: deploy to self-destructing VM [TODO]





This is not an official Google product.
