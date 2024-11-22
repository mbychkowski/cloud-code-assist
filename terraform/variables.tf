variable "project_id" {
  description = "Unique project id for your Google Cloud project where resources will be created."
  type        = string
}

variable "customer_id" {
  description = "Short (3-5 char) id to be added to all resources that will be created."
  type        = string
  default     = "gcp"
}

variable "region" {
  description = "Default region to be added to all resources that will be created."
  type        = string
  default     = "us-central1"
}
