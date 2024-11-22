# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  deletion_protection        = false
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-private-cluster"

  project_id                 = local.project.id
  name                       = "gke-${var.customer_id}"
  region                     = var.region
  network                    = module.vpc.network_name
  subnetwork                 = "sn-${var.customer_id}-usc1"
  ip_range_pods              = "sn-${var.customer_id}-usc1-pods1"
  ip_range_services          = "sn-${var.customer_id}-usc1-svcs1"
  horizontal_pod_autoscaling = true
  release_channel            = "RAPID" # RAPID was chosen for L4 support.
  kubernetes_version         = "1.29"  # We need the tip of 1.28 or 1.29 (not just default)
  create_service_account     = false
  service_account            = module.sa_gke_cluster.email
  # Google Cloud Storage (GCS) Fuse
  gcs_fuse_csi_driver        = false
  # enable_private_endpoint    = true
  enable_private_nodes       = true
  # master_ipv4_cidr_block     = "10.0.0.0/28"
  # master_authorized_networks = [{ cidr_block = "${var.subnet}", display_name = "internal" }]
  master_authorized_networks = [{ cidr_block = "0.0.0.0/0", display_name = "all" }]
  # Need to allow 48 hour window in rolling 32 days For `maintenance_start_time`
  # & `end_time` only the specified time of the day is used, the specified date
  # is ignored (https://cloud.google.com/composer/docs/specify-maintenance-windows#terraform)
  maintenance_recurrence = "FREQ=WEEKLY;BYDAY=SU"
  maintenance_start_time = "2023-01-02T07:00:00Z"
  maintenance_end_time   = "2023-01-02T19:00:00Z"

  depends_on = [
    module.vpc,
    module.cloud-nat,
    module.sa_gke_cluster,
  ]
}

###############################
##### 1) SERVICE ACCOUNTS #####
###############################

# Create a service account for GKE cluster
module "sa_gke_cluster" {
  source       = "terraform-google-modules/service-accounts/google"
  project_id   = local.project.id
  names        = ["sa-${var.customer_id}-gke-cluster"]
  display_name = "TF - GKE cluster SA"
  project_roles = [
    "${local.project.id}=>roles/artifactregistry.reader",
    "${local.project.id}=>roles/cloudtrace.agent",
    "${local.project.id}=>roles/container.developer",
    "${local.project.id}=>roles/container.nodeServiceAgent",
    "${local.project.id}=>roles/logging.logWriter",
    "${local.project.id}=>roles/monitoring.metricWriter",
    "${local.project.id}=>roles/monitoring.viewer",
    "${local.project.id}=>roles/stackdriver.resourceMetadata.writer"
  ]
}

# GKE Workload Identity
# resource "google_service_account_iam_binding" "sa_gke_cluster_wi_binding" {
#   service_account_id = google_service_account.sa_gke_cluster.name
#   role               = "roles/iam.workloadIdentityUser"
#   members = [
#     "serviceAccount:${local.project.id}.svc.id.goog[${var.job_namespace}/k8s-sa-cluster]",
#   ]
#   depends_on = [
#     module.gke
#   ]
# }