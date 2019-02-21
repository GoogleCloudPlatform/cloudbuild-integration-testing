# E2E testing on GCB using docker-compose

This is a demo of running scripts against a docker-compose environment as part of a [Google Cloud Build](https://cloud.google.com/cloud-build/) invocation

## To run

Prerequisite:
Build the [docker-compose community builder](https://github.com/GoogleCloudPlatform/cloud-builders-community/tree/master/docker-compose) and push to [Google Container Registry](https://cloud.google.com/container-registry/) in your GCP project

Run command:
`gcloud builds submit .`

This is not an official Google product.