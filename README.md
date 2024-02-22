# tf-gcp-infra

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
- Instance:
  - Name vpc
  - image: image name build by packer
  - network - under vpcs created
  - subnetworks - under subnetworks
  - tags: to match the firewall rules
- FireWall Rules:
  - Allow-App-Port: Allows traffic on specified application port.
  - Deny-SSH: Denies SSH traffic.

## Terraform Initialize

Terraform initializes your working directory and prepares it for other Terraform commands such as terraform plan or terraform apply

## Terraform Validation

Terraform configurations are validated to ensure correctness and prevent misconfigurations.

### Running Terraform Validation

To validate, plan and apply Terraform configurations, run the following command:

```bash
terraform init
terraform validate
terraform plan -var-file="values.tfvars file"     
terraform apply -var-file="values.tfvars file" 