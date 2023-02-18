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

## Project structure

```
.
├── README.md                 <-- This file
├── projects                  <-- Projects that use this repo
    ├── demo                  <-- The demo project, see README.md for more info
    ├── prod                  <-- TBD
    .
├── modules                   <-- Terraform modules
    ├── network               <-- Terraform module for VPC Network
    ├── gar                   <-- Terraform module for GAR Google Artifact Registry
    ├── gke                   <-- Terraform module for GKE Kubernetes cluster
    ├── ingress               <-- Terraform module for Ingress Controller
    ├── cicd                  <-- Terraform module for Continuous Integration and Continuous Delivery
    ├── db                    <-- Terraform module for Cloud SQL
    ├── redis                 <-- Terraform module for Cloud Memorystore Redis
    .
.
```

## License

[MIT](LICENSE)
