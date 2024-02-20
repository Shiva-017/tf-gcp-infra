# tf-gcp-infra (for the demo)

This project aims to automate infrastructure provisioning using Terraform and Google Cloud Platform (GCP).

## Overview

The infrastructure is defined as code using Terraform, ensuring reproducibility and consistency across environments. It provisions a Virtual Private Cloud (VPC) named `webapp-vpc` on GCP, along with custom subnetworks and routes for various components of the application.

### Infrastructure Details

- VPC Name: `webapp-vpc`
- Subnets:
  - `webapp` Subnet: CIDR /24, Gateway: 10.0.1.1
  - `db` Subnet: CIDR /24, Gateway: 10.0.2.1
- Route:
  - Name: `webapp-route`
  - Destination IP Range: 0.0.0.0/0
- FireWall Rules:
  - 

## Terraform Initialize

Terraform initializes your working directory and prepares it for other Terraform commands such as terraform plan or terraform apply

## Terraform Validation

Terraform configurations are validated to ensure correctness and prevent misconfigurations.

### Running Terraform Validation

To validate Terraform configurations, run the following command:

```bash
terraform init
terraform validate
```

## Workflow

GitHub Actions workflows are set up to automatically check the Terraform validation status which allows for merging the branch to main.

## Prerequisites

Ensure you have the following installed:

- Terraform
- Google Cloud SDK (gcloud) for auth

## resources
for writing configuration - https://developer.hashicorp.com/terraform/language
for creating multiple vpc - https://developer.hashicorp.com/terraform/language/meta-arguments/for_each
