resource "aws_ecr_repository" "app" {
  #checkov:skip=CKV_AWS_136:Existing dev ECR repository uses AES256 encryption; production will use KMS encryption from creation.

  name                 = "${var.project_name}-${var.environment}-app"
  image_tag_mutability = "IMMUTABLE"

  lifecycle {
    prevent_destroy = true
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-app"
    Project     = var.project_name
    Environment = var.environment
  }
}