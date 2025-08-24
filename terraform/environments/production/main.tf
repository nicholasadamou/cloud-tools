# Production environment configuration
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Provider configuration for production
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "production"
      Project     = "cloud-tools"
      ManagedBy   = "terraform"
      Owner       = "ops-team"
      CostCenter  = "engineering"
    }
  }
}

# Call the main module with production-specific variables
module "cloud_tools" {
  source = "../../"

  # Environment configuration
  environment = "production"
  aws_region  = var.aws_region

  # S3 Configuration - production settings
  enable_s3_versioning         = true
  s3_lifecycle_expiration_days = 90 # Longer retention for prod

  # DynamoDB Configuration - production settings
  dynamodb_billing_mode                  = "PAY_PER_REQUEST"
  enable_dynamodb_point_in_time_recovery = true # Important for prod

  # Lambda Configuration - production settings
  lambda_timeout     = 300  # Full timeout for prod
  lambda_memory_size = 1024 # More memory for prod

  # CloudWatch Configuration - production settings
  log_retention_in_days = 30 # Longer retention for prod
}

# Production-specific resources

# Enhanced monitoring and alerting for production
resource "aws_budgets_budget" "prod_budget" {
  name         = "cloud-tools-prod-budget"
  budget_type  = "COST"
  limit_amount = "100"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    dimension {
      key   = "TagKeyValue"
      values = ["Environment$production"]
    }
  }

  cost_filter {
    dimension {
      key   = "TagKeyValue"
      values = ["Project$cloud-tools"]
    }
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 50
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.notification_emails
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.notification_emails
  }
}

# SNS topic for production alerts
resource "aws_sns_topic" "prod_alerts" {
  name              = "cloud-tools-prod-alerts"
  kms_master_key_id = "alias/aws/sns"

  tags = {
    Environment = "production"
    Project     = "cloud-tools"
  }
}

resource "aws_sns_topic_subscription" "prod_email_alerts" {
  count     = length(var.notification_emails)
  topic_arn = aws_sns_topic.prod_alerts.arn
  protocol  = "email"
  endpoint  = var.notification_emails[count.index]
}

# Production-specific outputs
output "prod_api_url" {
  description = "Production API Gateway URL"
  value       = module.cloud_tools.api_gateway_url
}

output "prod_environment_info" {
  description = "Production environment information"
  value = {
    environment    = "production"
    api_url        = module.cloud_tools.api_gateway_url
    s3_bucket      = module.cloud_tools.s3_bucket_name
    dynamodb_table = module.cloud_tools.dynamodb_table_name
    sqs_queue_url  = module.cloud_tools.sqs_queue_url
  }
  sensitive = true
}
