output "s3_bucket_name" {
  description = "Name of the S3 bucket for file storage"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3.bucket_arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = module.dynamodb.table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = module.dynamodb.table_arn
}

output "sqs_queue_url" {
  description = "URL of the SQS queue"
  value       = module.sqs.queue_url
}

output "sqs_queue_arn" {
  description = "ARN of the SQS queue"
  value       = module.sqs.queue_arn
}

output "sqs_dead_letter_queue_url" {
  description = "URL of the SQS dead letter queue"
  value       = module.sqs.dead_letter_queue_url
}

output "api_gateway_url" {
  description = "Base URL of the API Gateway"
  value       = module.api_gateway.api_gateway_url
}

output "api_gateway_stage" {
  description = "Stage name of the API Gateway"
  value       = module.api_gateway.stage_name
}

output "lambda_convert_function_name" {
  description = "Name of the convert Lambda function"
  value       = module.lambda.convert_function_name
}

output "lambda_compress_function_name" {
  description = "Name of the compress Lambda function"
  value       = module.lambda.compress_function_name
}

output "lambda_process_function_name" {
  description = "Name of the process Lambda function"
  value       = module.lambda.process_function_name
}

output "cloudwatch_log_groups" {
  description = "CloudWatch log groups created"
  value       = module.cloudwatch.log_groups
}

# Environment configuration for application
output "environment_config" {
  description = "Environment configuration for the application"
  value = {
    AWS_REGION      = var.aws_region
    S3_BUCKET_NAME  = module.s3.bucket_name
    DDB_TABLE_NAME  = module.dynamodb.table_name
    SQS_QUEUE_NAME  = var.sqs_queue_name
    SQS_QUEUE_URL   = module.sqs.queue_url
    API_GATEWAY_URL = module.api_gateway.api_gateway_url
    ENVIRONMENT     = var.environment
  }
  sensitive = false
}

# IAM roles for Lambda functions
output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = module.iam.lambda_execution_role_arn
}

# Security group IDs (if VPC is used)
output "security_groups" {
  description = "Security group IDs created"
  value = {
    lambda_sg = try(module.lambda.security_group_id, "")
  }
}
