# Development environment configuration
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Provider configuration for development
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "dev"
      Project     = "cloud-tools"
      ManagedBy   = "terraform"
      Owner       = "development-team"
    }
  }
}

# Call the main module with development-specific variables
module "cloud_tools" {
  source = "../../"

  # Environment configuration
  environment = "dev"
  aws_region  = var.aws_region

  # S3 Configuration - development settings
  enable_s3_versioning         = true
  s3_lifecycle_expiration_days = 7 # Shorter retention for dev

  # DynamoDB Configuration - development settings
  dynamodb_billing_mode                  = "PAY_PER_REQUEST"
  enable_dynamodb_point_in_time_recovery = false # Not needed for dev

  # Lambda Configuration - development settings
  lambda_timeout     = 60  # Shorter timeout for dev
  lambda_memory_size = 512 # Less memory for dev

  # CloudWatch Configuration - development settings
  log_retention_in_days = 3 # Shorter retention for dev
}

# Development-specific resources
resource "aws_budgets_budget" "dev_budget" {
  name         = "cloud-tools-dev-budget"
  budget_type  = "COST"
  limit_amount = "10"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    dimension {
      key           = "Environment"
      values        = ["dev"]
      match_options = ["EQUALS"]
    }
  }

  cost_filter {
    dimension {
      key           = "Project"
      values        = ["cloud-tools"]
      match_options = ["EQUALS"]
    }
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.notification_email]
  }
}

# Development-specific outputs
output "dev_api_url" {
  description = "Development API Gateway URL"
  value       = module.cloud_tools.api_gateway_url
}

output "dev_environment_info" {
  description = "Development environment information"
  value = {
    environment    = "dev"
    api_url        = module.cloud_tools.api_gateway_url
    s3_bucket      = module.cloud_tools.s3_bucket_name
    dynamodb_table = module.cloud_tools.dynamodb_table_name
    sqs_queue_url  = module.cloud_tools.sqs_queue_url
  }
}
