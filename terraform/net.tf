# Copyright 2023 Google LLC All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module "vpc" {
  source  = "terraform-google-modules/network/google"

  project_id   = local.project.id
  network_name = "vpc-${var.customer_id}"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "sn-${var.customer_id}-usc1"
      subnet_ip             = "10.11.0.0/20"
      subnet_region         = "us-central1"
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "TF - Subnet for us-central1"
      subnet_private_access = true
    },
    {
      subnet_name           = "sn-${var.customer_id}-usw1"
      subnet_ip             = "10.12.0.0/20"
      subnet_region         = "us-west1"
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "TF - Subnet for us-west1"
      subnet_private_access = true
    },
    {
      subnet_name           = "sn-${var.customer_id}-euw1"
      subnet_ip             = "10.21.0.0/20"
      subnet_region         = "europe-west1"
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "TF - Subnet for europe-west1"
      subnet_private_access = true
    },
    {
      subnet_name           = "sn-${var.customer_id}-ase1"
      subnet_ip             = "10.31.0.0/20"
      subnet_region         = "asia-southeast1"
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "TF - Subnet for asia-southeast1"
      subnet_private_access = true
    }
  ]

  secondary_ranges = {
    "sn-${var.customer_id}-usc1" = [
      {
        range_name    = "sn-${var.customer_id}-usc1-pods1"
        ip_cidr_range = "10.111.0.0/16"
      },
      {
        range_name    = "sn-${var.customer_id}-usc1-svcs1"
        ip_cidr_range = "10.11.16.0/26"
      },
    ],
    "sn-${var.customer_id}-usw1" = [
      {
        range_name    = "sn-${var.customer_id}-usw1-pods1"
        ip_cidr_range = "10.112.0.0/16"
      },
      {
        range_name    = "sn-${var.customer_id}-usw1-svcs1"
        ip_cidr_range = "10.12.16.0/26"
      },
    ],
    "sn-${var.customer_id}-euw1" = [
      {
        range_name    = "sn-${var.customer_id}-euw1-pods1"
        ip_cidr_range = "10.121.0.0/16"
      },
      {
        range_name    = "sn-${var.customer_id}-euw1-svcs1"
        ip_cidr_range = "10.21.16.0/26"
      },
    ],
    "sn-${var.customer_id}-ase1" = [
      {
        range_name    = "sn-${var.customer_id}-ase1-pods1"
        ip_cidr_range = "10.131.0.0/16"
      },
      {
        range_name    = "sn-${var.customer_id}-ase1-svcs1"
        ip_cidr_range = "10.31.16.0/26"
      },
    ]
  }
}

resource "google_compute_router" "router" {
  for_each   = toset(module.vpc.subnets_regions)
  project    = local.project.id
  name       = "nat-router-${var.customer_id}-${each.key}"
  network    = module.vpc.network_name
  region     = each.key

  depends_on = [ module.vpc ]
}

module "cloud-nat" {
  for_each                           = toset(module.vpc.subnets_regions)
  source                             = "terraform-google-modules/cloud-nat/google"
  project_id                         = local.project.id
  region                             = each.key
  router                             = "nat-router-${var.customer_id}-${each.key}"
  name                               = "nat-${var.customer_id}-${each.key}"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
