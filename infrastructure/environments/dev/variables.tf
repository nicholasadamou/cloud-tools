variable "aws_region" {
  description = "AWS region for development environment"
  type        = string
  default     = "us-east-1"
}

variable "notification_email" {
  description = "Email address for budget notifications"
  type        = string
  default     = "dev-team@example.com"
}
