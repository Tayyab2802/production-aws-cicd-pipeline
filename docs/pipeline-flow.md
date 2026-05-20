# CI/CD Pipeline Flow

This project uses separate development and production pipelines to simulate a more realistic cloud deployment workflow.

The overall goal was to move beyond a simple “push and deploy” setup and instead introduce validation, deployment promotion, security scanning, and controlled production releases.

---

# Pipeline Overview

```text
dev branch
    ↓
Dev Pipeline
    ↓
Validation + Security Scanning
    ↓
Automatic Deployment to Dev
    ↓
Dev Environment Testing
    ↓
Merge dev into main
    ↓
Prod Pipeline
    ↓
Validation + Security Scanning
    ↓
Manual Production Approval
    ↓
Deployment to Production
```

---

# Development Pipeline

The development pipeline runs automatically whenever changes are pushed to the `dev` branch.

The purpose of the development environment is rapid iteration and testing.

## Development Flow

```text
Push changes to dev
    ↓
Terraform formatting check
    ↓
Terraform validation
    ↓
tfsec infrastructure scan
    ↓
Checkov infrastructure scan
    ↓
Docker image build
    ↓
Trivy vulnerability scan
    ↓
Save validated Docker image as artifact
    ↓
Deployment job starts only if validation succeeds
    ↓
Load same validated Docker image
    ↓
Push image to Amazon ECR
    ↓
Terraform apply for dev environment
    ↓
ECS deploys updated container image
    ↓
Application Load Balancer serves updated dev application
```

The development pipeline is designed to automatically block deployment if validation or security scanning fails.

---

# Production Pipeline

Production deployments follow a controlled promotion workflow.

Changes are first validated in the development environment before being promoted into production.

## Production Flow

```text
Merge dev into main
    ↓
Production pipeline starts
    ↓
Terraform formatting check
    ↓
Terraform validation
    ↓
tfsec infrastructure scan
    ↓
Checkov infrastructure scan
    ↓
Docker image build
    ↓
Trivy vulnerability scan
    ↓
Manual approval required
    ↓
Push image to production ECR
    ↓
Terraform apply for production environment
    ↓
ECS deploys updated production container image
    ↓
Application Load Balancer serves updated production application
```

This introduces a controlled deployment gate between development and production environments.

---

# Deployment Blocking

The pipeline is configured to prevent deployment if validation or security scanning fails.

```text
Validation or scan fails
    ↓
Deployment job does not run
```

This ensures insecure or invalid infrastructure changes are not automatically deployed.

Production deployments also require manual approval before deployment continues.

```text
Validation succeeds
    ↓
Production deployment pauses
    ↓
Manual approval required
    ↓
Deployment proceeds
```

---

# Docker Artifact Reuse

The Docker image is built once during validation and then reused during deployment.

```text
Build image
    ↓
Scan image
    ↓
Save image artifact
    ↓
Deploy same validated image
```

This avoids rebuilding a different image during deployment and ensures the deployed image is the same one that passed validation.

---

# Image Versioning

Docker images are tagged using the Git commit SHA.

Example:

```text
production-pipeline-dev-app:<commit-sha>
production-pipeline-prod-app:<commit-sha>
```

This makes deployments traceable and prevents image tags from being overwritten.

---

# Final Workflow Summary

```text
Development environment
→ automatic validation and deployment

Production environment
→ validation, manual approval, controlled deployment
```