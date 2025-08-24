variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "resource_suffix" {
  description = "Random suffix for resource naming"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for permissions"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for permissions"
  type        = string
}

variable "sqs_queue_arn" {
  description = "ARN of the SQS queue for permissions"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
