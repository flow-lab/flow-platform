SHELL := /bin/bash

REGION_ID := europe-west4
ZONE_ID := europe-west4-a
PROJECT_ID := $(shell gcloud config get-value project)

create:
	gsutil mb -p ${PROJECT_ID} -l ${REGION_ID} gs://${PROJECT_ID}-terraform-state
	gsutil versioning set on gs://${PROJECT_ID}-terraform-state