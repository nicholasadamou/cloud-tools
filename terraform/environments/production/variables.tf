variable "aws_region" {
  description = "AWS region for production environment"
  type        = string
  default     = "us-east-1"
}

variable "notification_emails" {
  description = "List of email addresses for production notifications"
  type        = list(string)
  default     = ["ops-team@example.com", "alerts@example.com"]
}

variable "allowed_cors_origins" {
  description = "List of allowed CORS origins for production"
  type        = list(string)
  default     = ["https://cloud-tools.example.com"]
}
