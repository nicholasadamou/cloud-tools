terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Variables for CloudWatch module
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

variable "log_retention_in_days" {
  description = "CloudWatch logs retention period in days"
  type        = number
  default     = 14
}

variable "lambda_function_names" {
  description = "List of Lambda function names for log groups"
  type        = list(string)
  default     = []
}

variable "sqs_queue_name" {
  description = "SQS queue name for monitoring"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for monitoring"
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

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = false
}

# Data sources
data "aws_region" "current" {}

# CloudWatch log groups for Lambda functions
resource "aws_cloudwatch_log_group" "lambda_logs" {
  count             = length(var.lambda_function_names)
  name              = "/aws/lambda/${var.lambda_function_names[count.index]}"
  retention_in_days = var.log_retention_in_days
  kms_key_id        = var.kms_key_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-${var.lambda_function_names[count.index]}-logs"
    Type = "LambdaLogs"
  })
}

# CloudWatch alarms for Lambda functions
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  count               = length(var.lambda_function_names)
  alarm_name          = "${var.project_name}-${var.environment}-${var.lambda_function_names[count.index]}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors lambda errors for ${var.lambda_function_names[count.index]}"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    FunctionName = var.lambda_function_names[count.index]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-${var.lambda_function_names[count.index]}-error-alarm"
    Type = "LambdaAlarm"
  })
}

# CloudWatch alarms for Lambda duration
resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  count               = length(var.lambda_function_names)
  alarm_name          = "${var.project_name}-${var.environment}-${var.lambda_function_names[count.index]}-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Average"
  threshold           = "30000" # 30 seconds
  alarm_description   = "This metric monitors lambda duration for ${var.lambda_function_names[count.index]}"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    FunctionName = var.lambda_function_names[count.index]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-${var.lambda_function_names[count.index]}-duration-alarm"
    Type = "LambdaAlarm"
  })
}

# SNS topic for alerts
resource "aws_sns_topic" "alerts" {
  name              = "${var.project_name}-${var.environment}-alerts-${var.resource_suffix}"
  kms_master_key_id = var.kms_key_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-alerts-topic"
    Type = "AlertsTopic"
  })
}

# CloudWatch dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-dashboard-${var.resource_suffix}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            for fname in var.lambda_function_names : [
              "AWS/Lambda",
              "Invocations",
              "FunctionName",
              fname
            ]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "Lambda Invocations"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/SQS",
              "NumberOfMessagesSent",
              "QueueName",
              var.sqs_queue_name
            ],
            [
              ".",
              "NumberOfMessagesReceived",
              ".",
              "."
            ]
          ]
          view   = "timeSeries"
          region = data.aws_region.current.name
          title  = "SQS Messages"
          period = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/DynamoDB",
              "ConsumedReadCapacityUnits",
              "TableName",
              var.dynamodb_table_name
            ],
            [
              ".",
              "ConsumedWriteCapacityUnits",
              ".",
              "."
            ]
          ]
          view   = "timeSeries"
          region = data.aws_region.current.name
          title  = "DynamoDB Capacity"
          period = 300
        }
      }
    ]
  })
}

# Outputs
output "log_groups" {
  description = "CloudWatch log groups created"
  value       = [for lg in aws_cloudwatch_log_group.lambda_logs : lg.name]
}

output "dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "alerts_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = aws_sns_topic.alerts.arn
}
