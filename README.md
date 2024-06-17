# Terraform-CI Docker Container

This repository contains the Dockerfile and necessary configurations to build a Docker container for continuous integration (CI) with Terraform, TFLint, Checkov, and Terraform-docs. This container can be used in CI/CD pipelines to automate infrastructure code validation and documentation generation.
## Tools Included

- **Terraform**: Infrastructure as Code (IaC) tool that lets you define both cloud and on-premise resources using a human-readable configuration language.

- **TFLint**: Linter for Terraform to detect errors and potential issues.

- **Checkov**: Static code analysis tool for Terraform to detect security and compliance issues.

- **Terraform-docs**: Utility to generate documentation from Terraform modules in various output formats.

## Getting Started

### Prerequisites

- Docker installed on your machine.
### Building the Docker Image Locally

To build the Docker image locally, run the following command in the root of this repository:

```sh
docker build -t terraform-ci .
```

### Running the Docker Container

To run the Docker container and access a shell inside it:

```sh
docker run -it --rm terraform-ci /bin/sh
```

## Using the Tools

Once inside the container, you can use the included tools as follows:

**Terraform**: `terraform [command]`

**TFLint**: `tflint [command]`

**Checkov**: `checkov [command]`

**Terraform-docs**: `terraform-docs [command]`

For example, to initialise a Terraform configuration:
```sh
terraform init
```

To lint your Terraform code:
```sh
tflint
```

To run security checks on your Terraform code:
```sh
checkov -d /path/to/terraform/code
```

To generate documentation for a Terraform module:
```sh
terraform-docs markdown /path/to/module
```
