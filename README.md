# Production-Ready AWS CI/CD Pipeline

A multi-environment AWS deployment pipeline built to simulate a realistic DevOps workflow using Terraform, Docker, GitHub Actions, ECS Fargate, and integrated security scanning.

## Overview

This project started as an attempt to move beyond a basic “push-to-deploy” student pipeline and instead build something that reflected how modern cloud deployment workflows are actually structured.

The focus was not only on automation, but also on understanding the operational side of CI/CD:

* how infrastructure state is managed safely
* how deployments are promoted between environments
* how security validation fits into a deployment lifecycle
* how immutable artifacts improve deployment consistency
* how infrastructure behaves when automation goes wrong

The pipeline uses Terraform for infrastructure provisioning, Docker for containerisation, GitHub Actions for CI/CD orchestration, and Amazon ECS Fargate for deployment.

A major part of the project involved debugging and improving the platform over time rather than simply building it once and leaving it untouched.

Some of the operational issues encountered during development included:

* Remote Terraform state conflicts
* Duplicate infrastructure creation
* Immutable ECR image tag collisions
* GitHub Actions workflow orchestration issues
* Environment separation between development and production
* Secure deployment gating and approval flows

Rather than following a fixed tutorial, the project evolved iteratively through troubleshooting, refactoring, and architectural improvements.

---

# Architecture

The platform is deployed on AWS using Terraform and consists of:

* Amazon VPC
* Public subnets across multiple Availability Zones
* Application Load Balancer (ALB)
* Amazon ECS Fargate
* Amazon ECR
* CloudWatch logging
* Terraform remote state in Amazon S3
* DynamoDB state locking
* GitHub Actions CI/CD pipelines

The application itself is a lightweight containerised FastAPI service used to validate deployment automation and container orchestration.

---

# CI/CD Workflow Design

The repository uses separate development and production deployment strategies.

## Development Workflow

Pushes to the `dev` branch automatically trigger the development pipeline.

### Development pipeline stages

1. Terraform formatting validation
2. Terraform validation
3. tfsec infrastructure security scanning
4. Checkov infrastructure security scanning
5. Docker image build
6. Trivy container vulnerability scanning
7. Docker artifact reuse
8. Push validated image to Amazon ECR
9. Terraform apply
10. ECS rolling deployment

The development environment is designed for rapid iteration and automated deployment.

---

## Production Workflow

Production deployments follow a promotion-based release model.

### Production flow

1. Changes are validated in the development environment
2. Tested changes are merged into `main`
3. Production validation and security scanning runs automatically
4. Deployment pauses for manual approval
5. Production deployment proceeds only after approval

This introduces a controlled deployment gate between development and production.


# Security Controls

The pipeline integrates multiple security validation layers.

## Infrastructure as Code Scanning

### tfsec

Used to detect Terraform misconfigurations such as:

* Open security groups
* Publicly exposed resources
* Missing encryption
* Weak network configurations

### Checkov

Used alongside tfsec to provide broader IaC coverage and policy validation.

Using both tools highlighted an important operational lesson:

> No single security scanner provides complete detection coverage.

Different scanners identified different weaknesses, reinforcing the importance of layered security validation.


## Container Security

### Trivy

Trivy is used to scan Docker images for:

* OS package vulnerabilities
* High and critical CVEs
* Vulnerable dependencies

The pipeline blocks deployment if severe vulnerabilities are detected.


# Terraform State Management

Terraform state is stored remotely using:

* Amazon S3
* DynamoDB locking

This allows:

* Shared infrastructure state between local development and GitHub Actions
* State locking to prevent concurrent modification
* Consistent deployments across environments

Separate Terraform state files are maintained for:

* Development
* Production

This separation prevents environment conflicts and accidental cross-environment changes.


# Immutable Container Deployments

Docker images are tagged using the Git commit SHA.

Example:
{aws-account}.dkr.ecr.{aws-region}.amazonaws.com/production-pipeline-dev-app:<commit-sha>


Amazon ECR image tag mutability is disabled.

This ensures:

* Deployments are traceable
* Existing artifacts cannot be overwritten
* ECS deployments are deterministic
* Previous application versions can be redeployed reliably if needed


# Environment Separation

The project intentionally separates:

* Development infrastructure
* Production infrastructure
* Development deployments
* Production deployments

The environments use:

* Separate Terraform state files
* Separate ECS services
* Separate ALBs
* Separate ECR repositories
* Separate GitHub deployment workflows

This models a realistic deployment promotion strategy.


# Repository Structure
```text

├── app/
│   ├── main.py
│   ├── requirements.txt
│   └── Dockerfile
│
├── infra/
│   ├── backend/
│   ├── environments/
│   │   ├── dev/
│   │   └── prod/
│   │
│   └── modules/
│       ├── alb/
│       ├── ecr/
│       ├── ecs/
│       └── network/
│
└── .github/
    └── workflows/
        ├── dev-pipeline.yml
        └── prod-pipeline.yml

```

# Key Lessons Learnt

A major focus of the project became understanding how deployment systems behave operationally rather than only making them work technically.

Some of the most valuable lessons included:

* Why Terraform remote state is critical for CI/CD consistency
* Why immutable image tagging matters in automated deployments
* How deployment orchestration can accidentally duplicate infrastructure
* The difference between development automation and production promotion
* Why deployment verification matters beyond successful pipeline runs
* The operational tradeoffs between speed and security

The project also reinforced that production-style systems are rarely built perfectly on the first attempt. Debugging and iteration are part of the engineering process.


# Future Improvements

Potential future enhancements include:

* HTTPS with ACM certificates
* WAF integration
* Private subnets with NAT gateways
* Terraform plan approval stages
* Kubernetes migration
* OIDC GitHub authentication
* Monitoring dashboards and alerting
* Centralised logging and SIEM integration


# Technologies Used

* Terraform
* AWS ECS Fargate
* Amazon ECR
* Amazon VPC
* Application Load Balancer
* Docker
* FastAPI
* GitHub Actions
* tfsec
* Checkov
* Trivy
* Amazon S3
* DynamoDB


# Why This Project Was Built

A lot of beginner CI/CD projects stop at:

```text
push code
    ↓
deploy app
```

This project intentionally went further by introducing:

* separate development and production environments
* remote Terraform state management
* immutable deployment artifacts
* deployment promotion between branches
* automated security validation
* controlled production deployment approval
* infrastructure troubleshooting and recovery

The objective was to build something that demonstrates not only tooling knowledge, but also an understanding of how deployment systems behave operationally.

# Final Notes

The final result is a multi-environment AWS deployment pipeline capable of:

* automated infrastructure provisioning
* containerised application deployment
* integrated infrastructure and container security scanning
* controlled production promotion
* immutable deployment versioning
* environment separation
* repeatable ECS deployments

More importantly, the project helped develop a practical understanding of how CI/CD systems are designed, debugged, and maintained in real environments.
