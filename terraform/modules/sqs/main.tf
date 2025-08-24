terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# Dead Letter Queue
resource "aws_sqs_queue" "dead_letter" {
  name = "${var.queue_name}-dlq-${var.environment}-${var.resource_suffix}"

  # DLQ configuration
  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  # Enable server-side encryption
  sqs_managed_sse_enabled = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-dlq"
    Type = "DeadLetterQueue"
  })
}

# Main SQS queue for job processing
resource "aws_sqs_queue" "main" {
  name = "${var.queue_name}-${var.environment}-${var.resource_suffix}"

  # Queue configuration
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  max_message_size           = 262144 # 256 KB
  delay_seconds              = 0
  receive_wait_time_seconds  = 20 # Long polling

  # Enable server-side encryption
  sqs_managed_sse_enabled = true

  # Dead letter queue configuration
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter.arn
    maxReceiveCount     = 3 # Move to DLQ after 3 failed attempts
  })

  # Redrive allow policy for the DLQ
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.dead_letter.arn]
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-queue"
    Type = "JobProcessingQueue"
  })
}

# SQS queue policy to allow S3 to publish messages
resource "aws_sqs_queue_policy" "main" {
  queue_url = aws_sqs_queue.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3ToSendMessages"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.main.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid    = "AllowLambdaToReceiveMessages"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = aws_sqs_queue.main.arn
      }
    ]
  })
}

