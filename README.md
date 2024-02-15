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

## Integration Testing

Integration tests are written using Jest to ensure that APIs function correctly by interacting with a MySQL server. These tests cover scenarios such as creating, updating, and retrieving user data. The database configuration variables are stored securely using GitHub Secrets and accessed via Sequelize for database connections.

### Running Integration Tests

To execute integration tests, run the following command:

```bash
npm test
```

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

- Node.js
- Terraform
- Google Cloud SDK (gcloud)

## Setup

1. Clone the repository.
2. Set up the necessary credentials and configurations for GCP and GitHub Secrets.
3. Modify any configurations as needed for your environment.
4. Execute Terraform to provision the infrastructure.
5. Run integration tests to verify functionality.
