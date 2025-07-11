terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

# Random suffix for bucket uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 bucket for GitOps lab demo
resource "aws_s3_bucket" "gitops_lab_demo" {
  bucket = "${var.bucket_name}-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "GitOps Lab Demo"
    Environment = var.environment
    Project     = "gitops-lab"
    ManagedBy   = "terraform"
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "gitops_lab_demo" {
  bucket = aws_s3_bucket.gitops_lab_demo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "gitops_lab_demo" {
  bucket = aws_s3_bucket.gitops_lab_demo.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "gitops_lab_demo" {
  bucket = aws_s3_bucket.gitops_lab_demo.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}