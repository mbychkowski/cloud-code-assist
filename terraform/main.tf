locals {
  project = {
    id      = var.project_id
    name    = data.google_project.project.name
    number  = data.google_project.project.number
  }
  _services = [
    "cloudbuild",
    "compute",
    "pubsub",
    "storage"
  ]
  service_account_cloud_services = (
    "${local.project.number}@cloudservices.gserviceaccount.com"
  )
  service_accounts_services_api = {
    for s in local._services : s => "${s}.googleapis.com"
  }
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_service_identity" "service_identity" {
  for_each   = local.service_accounts_services_api
  provider   = google-beta
  project    = local.project.id
  service    = each.value
}
