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

variable "queue_name" {
  description = "Name of the SQS queue"
  type        = string
  default     = "cloud-tools-jobs-queue"
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout for SQS messages in seconds"
  type        = number
  default     = 900 # 15 minutes
}

variable "message_retention_seconds" {
  description = "Message retention period in seconds"
  type        = number
  default     = 1209600 # 14 days
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
