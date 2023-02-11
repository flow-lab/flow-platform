resource "google_project_iam_custom_role" "gcp_deploy" {
  role_id     = "gcpdeploy"
  title       = "GCP deployment role"
  description = "Deploy infra for microservice to GCP."
  permissions = [
    "pubsub.topics.create",
    "pubsub.topics.get",
    "pubsub.topics.getIamPolicy",
    "pubsub.topics.setIamPolicy",
    "pubsub.topics.attachSubscription",
    "pubsub.subscriptions.create",
    "pubsub.subscriptions.delete",
    "pubsub.subscriptions.get",
    "pubsub.subscriptions.getIamPolicy",
    "pubsub.subscriptions.setIamPolicy",
    "pubsub.subscriptions.update",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.create",
    "iam.serviceAccounts.update",
    "iam.serviceAccountKeys.create",
    "iam.serviceAccountKeys.get",
    "iam.serviceAccountKeys.delete",
    "iam.roles.create",
    "iam.roles.undelete",
    "iam.roles.get",
    "iam.roles.update",
    "iam.roles.delete",
    "container.clusters.get",
    "compute.instanceGroupManagers.get",
    "compute.networks.get",
    "compute.networks.removePeering",
    "compute.globalAddresses.createInternal",
    "compute.globalAddresses.deleteInternal",
    "compute.globalAddresses.get",
    "servicenetworking.services.get",
    "servicenetworking.services.addPeering",
    "servicenetworking.services.addSubnetwork",
    "servicenetworking.operations.list",
    "servicenetworking.operations.get",
    "servicenetworking.operations.delete",
    "servicenetworking.operations.cancel",
    "resourcemanager.projects.get",
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.projects.setIamPolicy",
    "compute.projects.get",
    "compute.projects.setCommonInstanceMetadata",
    "compute.projects.setDefaultNetworkTier",
    "compute.projects.setDefaultServiceAccount",
    "cloudsql.backupRuns.create",
    "cloudsql.backupRuns.get",
    "cloudsql.backupRuns.list",
    "cloudsql.databases.create",
    "cloudsql.databases.get",
    "cloudsql.databases.list",
    "cloudsql.databases.update",
    "cloudsql.instances.addServerCa",
    "cloudsql.instances.clone",
    "cloudsql.instances.connect",
    "cloudsql.instances.create",
    "cloudsql.instances.demoteMaster",
    "cloudsql.instances.export",
    "cloudsql.instances.failover",
    "cloudsql.instances.get",
    "cloudsql.instances.import",
    "cloudsql.instances.list",
    "cloudsql.instances.listServerCas",
    "cloudsql.instances.promoteReplica",
    "cloudsql.instances.resetSslConfig",
    "cloudsql.instances.restart",
    "cloudsql.instances.restoreBackup",
    "cloudsql.instances.rotateServerCa",
    "cloudsql.instances.startReplica",
    "cloudsql.instances.stopReplica",
    "cloudsql.instances.truncateLog",
    "cloudsql.instances.update",
    "cloudsql.instances.delete",
    "cloudsql.sslCerts.create",
    "cloudsql.sslCerts.get",
    "cloudsql.sslCerts.list",
    "cloudsql.users.create",
    "cloudsql.users.list",
    "cloudsql.users.update",
    "container.secrets.create",
    "container.secrets.get",
    "container.secrets.list",
    "container.secrets.update",
    "container.secrets.delete",
    "container.configMaps.create",
    "container.configMaps.delete",
    "container.configMaps.get",
    "container.configMaps.list",
    "container.configMaps.update",
  ]
}

resource "google_project_iam_custom_role" "terraform_state" {
  role_id     = "terraformstate"
  title       = "Terraform state role"
  description = "Create or update terraform state."
  permissions = [
    "storage.buckets.get",
    "storage.buckets.getIamPolicy",
    "storage.buckets.list",
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.get",
    "storage.objects.getIamPolicy",
    "storage.objects.list",
    "storage.objects.setIamPolicy",
    "storage.objects.update"
  ]
}

resource "google_service_account" "gcp_deployment_service_account" {
  account_id   = "gcp-deployment"
  display_name = "Service Account for deployment of microservice infrastructure to GCP. Used by terraform."
}

resource "google_project_iam_binding" "binding_gcpdeployment" {
  role    = google_project_iam_custom_role.gcp_deploy.id
  project = var.project_id

  members = [
    "serviceAccount:${google_service_account.gcp_deployment_service_account.email}"
  ]
}

resource "google_project_iam_binding" "binding_terraform_state" {
  role    = google_project_iam_custom_role.terraform_state.id
  project = var.project_id

  members = [
    "serviceAccount:${google_service_account.gcp_deployment_service_account.email}"
  ]
}