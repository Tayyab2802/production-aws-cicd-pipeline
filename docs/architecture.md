# AWS Architecture

This project uses a multi-environment AWS architecture designed to support automated deployments, container orchestration, infrastructure separation, and controlled promotion between development and production environments.

The infrastructure is provisioned entirely using Terraform.

---

# Architecture Overview

The platform consists of:

- Amazon VPC
- Public subnets across multiple Availability Zones
- Application Load Balancer (ALB)
- Amazon ECS Fargate
- Amazon ECR
- GitHub Actions CI/CD pipelines
- Terraform remote state in Amazon S3
- DynamoDB state locking

The application itself is a lightweight FastAPI container used to validate deployment automation and ECS orchestration.

---

# Networking Architecture

## Virtual Private Cloud (VPC)

A dedicated VPC was created to isolate the application infrastructure.

```text
CIDR: 10.0.0.0/16
```

The VPC acts as the main networking boundary for both development and production environments.

Separate VPC resources are created for:

- Development
- Production

This prevents infrastructure overlap between environments.

---

# Public Subnets

Two public subnets are deployed across separate Availability Zones:

```text
eu-west-2a
eu-west-2b
```

The use of multiple Availability Zones improves availability and allows traffic distribution across ECS tasks.

Example subnet ranges:

```text
10.0.1.0/24
10.0.2.0/24
```

The subnets are associated with a public route table connected to an Internet Gateway.

---

# Internet Gateway

An Internet Gateway is attached to the VPC to allow external connectivity.

This enables:

- Public access to the Application Load Balancer
- Outbound internet access for ECS tasks
- Connectivity for deployment operations

---

# Application Load Balancer (ALB)

The Application Load Balancer acts as the public entry point to the application.

Responsibilities include:

- Receiving HTTP traffic
- Performing health checks
- Routing traffic to ECS tasks
- Distributing requests across Availability Zones

The ALB improves both scalability and availability by balancing traffic across multiple ECS tasks.

---

# ECS Fargate

The application is deployed using Amazon ECS Fargate.

Fargate was chosen because it removes the need to manage EC2 instances while still supporting scalable container deployments.

The ECS service is responsible for:

- Running the FastAPI container
- Pulling container images from Amazon ECR
- Deploying updated task revisions
- Integrating with the ALB target group

The application runs on:

```text
Port 8000
```

---

# Amazon ECR

Amazon Elastic Container Registry (ECR) is used to store Docker images.

The CI/CD pipeline:

- Builds Docker images
- Scans them for vulnerabilities
- Pushes validated images to ECR
- Deploys images into ECS

Separate ECR repositories are maintained for:

- Development
- Production

This supports environment separation and deployment promotion.

---


# Terraform Remote State

Terraform state is stored remotely using:

- Amazon S3
- DynamoDB locking

## S3 Backend

The S3 backend stores Terraform state centrally so both local development and GitHub Actions use the same infrastructure state.

This prevents:

- Infrastructure duplication
- State inconsistency
- Conflicting deployments

---

## DynamoDB Locking

DynamoDB locking prevents multiple Terraform operations from modifying infrastructure simultaneously.

This reduces the risk of:

- State corruption
- Concurrent deployment conflicts
- Partial infrastructure changes

Separate Terraform state files are maintained for:

```text
development
production
```

---

# Environment Separation

The project intentionally separates development and production infrastructure.

Each environment has:

- Separate Terraform state
- Separate ECS services
- Separate ALBs
- Separate ECR repositories
- Separate deployment workflows

This models a more realistic deployment promotion strategy.

---

# CI/CD Integration

GitHub Actions is used to automate:

- Infrastructure validation
- Security scanning
- Docker image builds
- Vulnerability scanning
- ECS deployments
- Production promotion

The deployment workflows interact directly with:

- Amazon ECR
- ECS
- Terraform remote state

---

# Security Validation

Infrastructure and container validation is integrated into the deployment lifecycle using:

- tfsec
- Checkov
- Trivy

The pipeline is configured to block deployment if validation fails.

This introduces automated security enforcement into the deployment process.

---

# Infrastructure Flow

```text
Developer
    ↓
GitHub Actions Pipeline
    ↓
Terraform Validation + Security Scanning
    ↓
Docker Image Build + Trivy Scan
    ↓
Push Validated Image to Amazon ECR
    ↓
Terraform Apply
    ↓
ECS Deployment
    ↓
Application Load Balancer
    ↓
End User Access
```

---

# Final Architecture Summary

The final architecture combines:

- Infrastructure as Code
- Container orchestration
- Deployment automation
- Security validation
- Remote state management
- Environment separation
- Controlled production promotion

The project was designed to demonstrate not only AWS deployment automation, but also the operational structure behind modern cloud delivery workflows.