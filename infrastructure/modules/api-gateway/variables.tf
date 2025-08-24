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

variable "convert_lambda_arn" {
  description = "ARN of the convert Lambda function"
  type        = string
}

variable "compress_lambda_arn" {
  description = "ARN of the compress Lambda function"
  type        = string
}

variable "convert_lambda_name" {
  description = "Name of the convert Lambda function"
  type        = string
}

variable "compress_lambda_name" {
  description = "Name of the compress Lambda function"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
}
