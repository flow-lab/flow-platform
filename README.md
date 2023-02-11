# Flow Platform

_Flow Platform_ is a platform built on Google Cloud Platform (GCP) that utilizes the power of GKE (Google
Kubernetes Engine) to provide a robust, scalable, and secure infrastructure for deploying, managing, and monitoring
applications. Flow Platform GCP leverages the Google infrastructure to provide a seamless experience for developers,
allowing them to focus on building and deploying applications without worrying about infrastructure management. With
Flow Platform GCP, teams can easily deploy, manage, and scale their applications on GCP, taking advantage of the
reliability and security that comes with the Google cloud.

## Status

Please note that this project is currently under development and should not be used in a production environment. While
we are making progress towards a stable release, there may still be bugs and unfinished features that need to be
addressed. If you are interested in using the production-ready version, please email to kontakt@flowlab.no and
the team will get back to you with more information.

## Capabilities

**Infrastructure as Code** - Infrastructure is defined as code and managed by Terraform. This allows for
    infrastructure to be versioned and managed in the same way as application code.
- **Continuous Delivery** - Flow Platform GCP is built on top of GitOps principles, allowing for continuous
    delivery of applications to the platform.
- **Security** - Flow Platform GCP is built on top of Google Cloud Platform, which provides a secure and reliable
    infrastructure for deploying applications.
- **Scalability** - Flow Platform GCP is built on top of Google Kubernetes Engine, which provides a scalable
    infrastructure for deploying applications.
- **Observability** - Flow Platform GCP is built on top of Google Cloud Platform, which provides a robust
    observability stack for monitoring applications.
- **Developer Experience** - Flow Platform GCP is built on top of Google Cloud Platform, which provides a
    developer experience that is familiar to developers.
- **Cost Optimization** - Flow Platform GCP is built on top of Google Cloud Platform, which provides a
    cost-optimized infrastructure for deploying applications.
- **Reliability** - Flow Platform GCP is built on top of Google Cloud Platform, which provides a reliable
    infrastructure for deploying applications.

## Getting started

```shell
# login to gcloud
gcloud auth login

# set project
gcloud config set project flow-platform

# set it to env var as well
export PROJECT_ID=$(gcloud config get-value project)

# set zone
gcloud config set compute/zone europe-west4-a

# create a terraform service account
gcloud iam service-accounts create terraform-admin \
  --display-name "Terraform admin account"
  
# grant the service account permission to manage GCP resources
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member serviceAccount:terraform-admin@${PROJECT_ID}.iam.gserviceaccount.com \
  --role roles/editor

# create a key for the service account 
gcloud iam service-accounts keys create ${HOME}/.config/gcloud/flow-platform-tf-admin.json \ 
    --iam-account=terraform-admin@${PROJECT_ID}.iam.gserviceaccount.com
   
# create a bucket for terraform state, see terraform-state directory and README.md for more info 
# terraform init
terraform init -backend-config="bucket=flow-platform-terraform-state" -backend-config="prefix=terraform" -backend-config="credentials=${HOME}/.config/gcloud/flow-platform-tf-admin.json"

# export vars for terraform
export TF_VAR_credentials=${HOME}/.config/gcloud/flow-platform-tf-admin.json
export TF_VAR_project_id=${PROJECT_ID}

# terraform plan
terraform plan

# terraform apply
# NOTE: 
# 1. this will create resources in GCP tha generate cost
# 2. Bunch of API needs to be enabled in GCP for the project manually and terraform will not do it for you, repeat this 
#    step until you get no errors
terraform apply

# get credentials for kubernetes cluster
gcloud container clusters get-credentials gke-0 --zone europe-west4-a --project ${PROJECT_ID}

# ready to use with k9s, kubectl, helm, etc
```

## License

[MIT](LICENSE)