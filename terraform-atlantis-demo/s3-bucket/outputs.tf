output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.gitops_lab_demo.id
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.gitops_lab_demo.arn
}

output "bucket_region" {
  description = "Region of the created S3 bucket"
  value       = aws_s3_bucket.gitops_lab_demo.region
}