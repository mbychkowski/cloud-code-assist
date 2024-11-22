# A Google Cloud platform

This repository, is meant for provisioning a demo platform to showcase various
aspects of Google Cloud as a complete architecture framework for deploying
applications.

## Technology Used
**Code management (GitHub)**
- [GitHub Actions](https://docs.github.com/en/actions)
- [GitHub CLI](https://github.com/cli/cli#installation)

**Google Cloud**
- [gcloud CLI](https://cloud.google.com/sdk/docs/install)

- [Artifact Registry](https://cloud.google.com/artifact-registry/docs)
- [Cloud Build](https://cloud.google.com/build/docs/overview)
- [Cloud Deploy](https://cloud.google.com/deploy/docs/overview)
- [GKE Autopilot](https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-overview)

**Infrastructure as Code**
- [Terraform](https://www.terraform.io/downloads.html)

**Platform Tooling**
- [Skaffold](https://skaffold.dev/docs/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Getting started

To use this repository it is recommended that you first create a [fork](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/fork-a-repo).

## Bootstrap

After creating a fork, there are a handful of quick bootrap scripts to get your
repository up and running.

1. Setup specific environment variables unique to your GitHub Repository and
Google Cloud Project. The script will request a couple inputs about the
environment and output `./.env` files with relevant variables.

    ```bash
    . ./scripts/bootstrap/01-setup-env.sh
    ```

    ```bash
    input(s):

    "Enter GitHub organization or owner [${_GITHUB_ORG}]: "
    "Enter GitHub repository name [${_GITHUB_REPO}]: "
    "Enter GCP project ID [${_GCP_PROJECT_ID}]: "
    "Enter default value region for this setup [${_GCP_LOCATION}]: "
    "Enter short (3-5 char) identifier for cloud resources (e.g. gcp) [$_GCP_CUSTOMER_ID]: "
    ```

    ```bash
    output:

    ./.env
    ```

2. Enable applicable Google Cloud APIs

    ```bash
    . ./scripts/bootstrap/02-enable-api.sh
    ```

3. Enable GitHub Actions by setting up variables in forked repository. GitHub
Actions leverages [Workload Identity Federation](https://cloud.google.com/blog/products/identity-security/secure-your-use-of-third-party-tools-with-identity-federation)
for "keyless" authentication. In this setup we use [Worklaod Identity Federation
through a Service Account](https://cloud.google.com/blog/products/identity-security/secure-your-use-of-third-party-tools-with-identity-federation) (`sa-terraform`).

    ```bash
    . ./scripts/bootstrap/03-enable-gh-actions.sh
    ```

4. Setup IAM permissions for Google Service Account `sa-terraform` to deploy
resources on our behalf.

    ```bash
    . ./scripts/bootstrap/04-enable-iam.sh
    ```

5. Finally we will setup Terraform [backend](https://cloud.google.com/docs/terraform/resource-management/store-state)
on Google Cloud Storage for when we start deploying our resources with Terraform
 through GitHub Actions.

    ```bash
    . ./scripts/bootstrap/05-setup-tf.sh
    ```
