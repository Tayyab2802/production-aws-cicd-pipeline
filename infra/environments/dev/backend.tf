terraform {
  backend "s3" {
    bucket         = "tayyab-terraform-state-prod"
    key            = "production-pipeline/dev/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}