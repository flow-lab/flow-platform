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

## Getting started

```shell
# login to gcloud
gcloud auth login

# set it to env var as well
export PROJECT_ID=$(gcloud config get-value project)

# set project
gcloud config set project ${PROJECT_ID}

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
terraform init -backend-config="bucket=${PROJECT_ID}-terraform-state" -backend-config="prefix=terraform" -backend-config="credentials=${HOME}/.config/gcloud/flow-platform-tf-admin.json"

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

# get credentials for kubernetes cluster from terraform output and remove " around the cluster name
export CLUSTER_NAME=$(terraform output | grep cluster_name | awk '{print $3}' | sed 's/"//g')
gcloud container clusters get-credentials ${CLUSTER_NAME} --zone europe-west4-a --project ${PROJECT_ID}

# ready to use with k9s, kubectl, helm, etc
```

## License

[MIT](LICENSE)
