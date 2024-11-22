# Terraform

This folder contains Terraform configuration files to provision the
infrastructure needed for this project.

## Prerequisites

The provisioning of **Terraform** resources in this step assumes the user has
already ran throuh the **bootstrap** setup outline [here]().

## Provisioning Infrastructure

The following steps will walk you through setting up **Terraform** to provision
infrastructure in Google Cloud.

1. Create remote state for Terraform in Google Cloud Storage and a Terraform
`tfvars` file using your project id to create unique variable names:

    ```bash
    bash ./scripts/bootstrap/05-setup-tf.sh
    ```

2. Deploy infrastructure with Terraform:

    ```bash
    cd ./terraform
    ```

    ```bash
    terraform init -backend-config="bucket=bkt-tfstate-$(gcloud config get project)"

    terraform plan -out=out.tfplan \
      -var "project_id=${GCP_PROJECT_ID}" \
      -var "customer_id=${GCP_CUSTOMER_ID}" \
      -var "region=${GCP_LOCATION}"

    terraform apply "out.tfplan"
    ```

> __Note:__ The deployment of cloud resources can take between 5 - 10 minutes.

> __Note:__ If you get the error: `Permission denied while using the Eventarc Service` you will need to run these Terraform commands to fix the error:

```bash
terraform plan -out=out.tfplan
terraform apply "out.tfplan"
```

## Tearing Down Infrastructure

1. Tear down all infrastructure created using Terraform:

    ```bash
    cd ./terraform
    terraform destroy
    ```

## Terraform Infrastructure Details

![Terraform architecture](/docs/images/arch.png)

### IAM bindings reference

**Project:** <i>[project_id]</i>

| members | description | roles |
|---|---|---|
|<b>user</b><br><small><i>User</i></small>|User to bootstrap project resources.|[roles/owner](https://cloud.google.com/iam/docs/understanding-roles#owner) |
|<b>`sa-terraform`</b><br><small><i>Service account</i></small>|Deploy Google Cloud resources via Terraform through GitHub Actions.| [roles/owner](https://cloud.google.com/iam/docs/understanding-roles#owner)|
|<b>`sa-<customer_id>-gke-cluster`</b><br><small><i>Service account</i></small>|Applications running on this cluster use this service account to call Google Cloud APIs| [roles/artifactregistry.reader](https://cloud.google.com/iam/docs/understanding-roles#artifactregistry.reader) · [roles/cloudtrace.agent](https://cloud.google.com/iam/docs/understanding-roles#cloudtrace.agent) · [roles/container.admin](https://cloud.google.com/iam/docs/understanding-roles#container.admin) · [roles/container.clusterAdmin](https://cloud.google.com/iam/docs/understanding-roles#container.clusterAdmin) · [roles/container.developer](https://cloud.google.com/iam/docs/understanding-roles#container.developer) · [roles/container.nodeServiceAgent](https://cloud.google.com/iam/docs/understanding-roles#container.nodeServiceAgent) · [roles/logging.logWriter](https://cloud.google.com/iam/docs/understanding-roles#logging.logWriter) · [roles/monitoring.metricWriter](https://cloud.google.com/iam/docs/understanding-roles#monitoring.metricWriter) · [roles/monitoring.viewer](https://cloud.google.com/iam/docs/understanding-roles#monitoring.viewer) · [roles/stackdriver.resourceMetadata.writer](https://cloud.google.com/iam/docs/understanding-roles#stackdriver.resourceMetadata.writer) · [roles/storage.admin](https://cloud.google.com/iam/docs/understanding-roles#storage.admin) · [roles/storage.objectUser](https://cloud.google.com/iam/docs/understanding-roles#storage.objectUser) |


### Files

| name | description | modules | resources |
|---|---|---|---|
| [main.tf](./main.tf) | Define Terraform local variabls and service account defaults. |  | `google_project_service_identity.service_identity` |
| [cicd.tf](./cicd.tf) | Define Artifact Registry repository for container images. |  | `google_artifact_registry_repository.repo` |
| [gke.tf](./gke.tf) | GKE cluster for transcoding jobs. | [`gke`](https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest/submodules/beta-autopilot-private-cluster) |  |
| [net.tf](./net.tf) | VPC network and firewall rules. | [`cloud-nat`](https://registry.terraform.io/modules/terraform-google-modules/cloud-nat/google/latest), [`vpc`](https://registry.terraform.io/modules/terraform-google-modules/network/google/latest) | `google_compute_router.router` |

### Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| project_id | Unique project ID to host project resources. | `string` | ✓ | "" |
| customer_id | Unique customer ID to name TF created resources. | `string` | ✓ | "gcp" |
| region | Region that will be used for all required resources. | `string` | ✓ | "us-central1" |

### Outputs

| name | description | sensitive | consumers |
|---|---|:---:|---|
| project_id | Unique project ID to host project resources. | ✓ | GKE |
| customer_id | Unique customer ID to name TF created resources. | x | GKE |
| region | Region that will be used for all required resources. | x | GKE |
