terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# DynamoDB table for job tracking
resource "aws_dynamodb_table" "main" {
  name         = "${var.table_name}-${var.environment}-${var.resource_suffix}"
  billing_mode = var.billing_mode
  hash_key     = "jobId"

  # Primary key attribute
  attribute {
    name = "jobId"
    type = "S"
  }

  # GSI for querying by status
  attribute {
    name = "status"
    type = "S"
  }

  # GSI for querying by user (if authentication is added later)
  attribute {
    name = "userId"
    type = "S"
  }

  # GSI for querying by creation time
  attribute {
    name = "createdAt"
    type = "S"
  }

  # Global Secondary Index for status queries
  global_secondary_index {
    name            = "StatusIndex"
    hash_key        = "status"
    range_key       = "createdAt"
    projection_type = "ALL"
  }

  # Global Secondary Index for user queries (future use)
  global_secondary_index {
    name            = "UserIndex"
    hash_key        = "userId"
    range_key       = "createdAt"
    projection_type = "ALL"
  }

  # TTL configuration for automatic cleanup
  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  # Point-in-time recovery
  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-jobs-table"
    Type = "JobTracking"
  })
}

# Point-in-time recovery configuration is now part of the main table resource
# This is configured within the aws_dynamodb_table resource using the point_in_time_recovery block

# Note: DynamoDB automatic backups are enabled by default for tables with point-in-time recovery
# For on-demand backups, use AWS CLI or console rather than Terraform
# CloudWatch contributor insights
resource "aws_dynamodb_contributor_insights" "main" {
  table_name = aws_dynamodb_table.main.name
}

# DynamoDB table items for initial setup (optional)
resource "aws_dynamodb_table_item" "system_status" {
  count      = 1
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key

  item = jsonencode({
    jobId = {
      S = "SYSTEM_STATUS"
    }
    status = {
      S = "active"
    }
    createdAt = {
      S = timestamp()
    }
    jobType = {
      S = "system"
    }
    description = {
      S = "System status monitoring entry"
    }
    ttl = {
      N = tostring(floor(timestamp() + 86400 * 365)) # 1 year TTL
    }
  })
}
