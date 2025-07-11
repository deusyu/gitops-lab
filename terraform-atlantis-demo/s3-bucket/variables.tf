variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Base name for S3 bucket"
  type        = string
  default     = "gitops-lab-demo"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}