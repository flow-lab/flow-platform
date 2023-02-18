# Demo project

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
gcloud iam service-accounts create tf-admin \
  --display-name "Terraform admin account"
  
# grant the service account permission to manage GCP resources
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member serviceAccount:tf-admin@${PROJECT_ID}.iam.gserviceaccount.com \
  --role roles/owner

# create a key for the tf-admin service account
gcloud iam service-accounts keys create ${HOME}/.config/gcloud/${PROJECT_ID}-tf-admin.json --iam-account=tf-admin@${PROJECT_ID}.iam.gserviceaccount.com
   
# create a bucket for terraform state, see terraform-state directory and README.md for more info 
# terraform init
terraform init -backend-config="bucket=${PROJECT_ID}-terraform-state" -backend-config="prefix=terraform" -backend-config="credentials=${HOME}/.config/gcloud/${PROJECT_ID}-tf-admin.json"

# export vars for terraform
export TF_VAR_credentials=${HOME}/.config/gcloud/${PROJECT_ID}-tf-admin.json
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

# generate key for gke-deployment service account for github actions or other CI/CD
gcloud iam service-accounts keys create ${HOME}/.config/gcloud/${PROJECT_ID}-gke-deployment.json --iam-account=gke-deployment@${PROJECT_ID}.iam.gserviceaccount.com

# to use in github actions use the following command to get the key into a single line string
cat ~/.config/gcloud/${PROJECT_ID}-gke-deployment.json | jq -r tostring
```