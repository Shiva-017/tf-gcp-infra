# tf-gcp-infra

This project aims to automate infrastructure provisioning using Terraform and Google Cloud Platform (GCP), and ensure proper functionality through integration tests.

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


## Terraform Validation

Terraform configurations are validated to ensure correctness and prevent misconfigurations.

### Running Terraform Validation

To validate Terraform configurations, run the following command:

```bash
npm run terraform-validate
```

## Workflow

GitHub Actions workflows are set up to automatically check the Terraform validation status and the success of integration tests.

## Prerequisites

Ensure you have the following installed:

- Terraform
- Google Cloud SDK (gcloud)

## resources
for creating multiple vpc - https://developer.hashicorp.com/terraform/language/meta-arguments/for_each
for writing configuration - https://developer.hashicorp.com/terraform/language