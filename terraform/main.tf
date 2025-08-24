# Data sources for common AWS resources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Random suffix for unique resource naming
resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  resource_suffix = random_id.suffix.hex
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
    Region      = data.aws_region.current.name
    AccountId   = data.aws_caller_identity.current.account_id
  }
}

# KMS key for encryption
resource "aws_kms_key" "main" {
  description             = "KMS key for ${var.project_name} ${var.environment} encryption"
  deletion_window_in_days = var.environment == "production" ? 30 : 7
  enable_key_rotation     = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-kms-key"
    Type = "Encryption"
  })
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project_name}-${var.environment}-key"
  target_key_id = aws_kms_key.main.key_id
}

# IAM roles and policies (must be created first)
module "iam" {
  source = "./modules/iam"

  project_name        = var.project_name
  environment         = var.environment
  resource_suffix     = local.resource_suffix
  s3_bucket_name      = module.s3.bucket_name
  dynamodb_table_name = var.dynamodb_table_name
  sqs_queue_arn       = module.sqs.queue_arn

  tags = local.common_tags

  depends_on = [module.s3, module.sqs]
}

# S3 bucket for file storage
module "s3" {
  source = "./modules/s3"

  project_name              = var.project_name
  environment               = var.environment
  resource_suffix           = local.resource_suffix
  bucket_prefix             = var.s3_bucket_prefix
  enable_versioning         = var.enable_s3_versioning
  lifecycle_expiration_days = var.s3_lifecycle_expiration_days
  kms_key_id                = aws_kms_key.main.arn

  tags = local.common_tags
}

# DynamoDB table for job tracking
module "dynamodb" {
  source = "./modules/dynamodb"

  project_name                  = var.project_name
  environment                   = var.environment
  resource_suffix               = local.resource_suffix
  table_name                    = var.dynamodb_table_name
  billing_mode                  = var.dynamodb_billing_mode
  enable_point_in_time_recovery = var.enable_dynamodb_point_in_time_recovery

  tags = local.common_tags
}

# SQS queue for job processing
module "sqs" {
  source = "./modules/sqs"

  project_name               = var.project_name
  environment                = var.environment
  resource_suffix            = local.resource_suffix
  queue_name                 = var.sqs_queue_name
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
  message_retention_seconds  = var.sqs_message_retention_seconds

  tags = local.common_tags
}

# CloudWatch resources for monitoring
module "cloudwatch" {
  source = "./modules/cloudwatch"

  project_name               = var.project_name
  environment                = var.environment
  resource_suffix            = local.resource_suffix
  log_retention_in_days      = var.log_retention_in_days
  enable_detailed_monitoring = var.enable_detailed_monitoring
  kms_key_id                 = aws_kms_key.main.arn

  # Lambda function names for log groups
  lambda_function_names = [
    module.lambda.convert_function_name,
    module.lambda.compress_function_name,
    module.lambda.process_function_name
  ]

  # SQS queue for monitoring
  sqs_queue_name = module.sqs.queue_name

  # DynamoDB table for monitoring
  dynamodb_table_name = module.dynamodb.table_name

  tags = local.common_tags

  depends_on = [module.lambda, module.sqs, module.dynamodb]
}

# Lambda functions for file processing
module "lambda" {
  source = "./modules/lambda"

  project_name       = var.project_name
  environment        = var.environment
  resource_suffix    = local.resource_suffix
  lambda_timeout     = var.lambda_timeout
  lambda_memory_size = var.lambda_memory_size
  lambda_runtime     = var.lambda_runtime
  kms_key_id         = aws_kms_key.main.arn

  # IAM role for Lambda functions
  lambda_execution_role_arn = module.iam.lambda_execution_role_arn

  # Environment variables for Lambda functions
  environment_variables = {
    AWS_REGION     = var.aws_region
    S3_BUCKET_NAME = module.s3.bucket_name
    DDB_TABLE_NAME = module.dynamodb.table_name
    SQS_QUEUE_URL  = module.sqs.queue_url
    ENVIRONMENT    = var.environment
    LOG_LEVEL      = var.environment == "production" ? "INFO" : "DEBUG"
  }

  tags = local.common_tags

  depends_on = [module.iam, module.s3, module.dynamodb, module.sqs]
}

# API Gateway for REST API
module "api_gateway" {
  source = "./modules/api-gateway"

  project_name         = var.project_name
  environment          = var.environment
  resource_suffix      = local.resource_suffix
  allowed_cors_origins = var.allowed_cors_origins
  enable_waf           = var.enable_waf
  kms_key_id           = aws_kms_key.main.arn

  # Lambda function integration
  convert_lambda_arn  = module.lambda.convert_function_arn
  compress_lambda_arn = module.lambda.compress_function_arn
  process_lambda_arn  = module.lambda.process_function_arn

  convert_lambda_name  = module.lambda.convert_function_name
  compress_lambda_name = module.lambda.compress_function_name
  process_lambda_name  = module.lambda.process_function_name

  tags = local.common_tags

  depends_on = [module.lambda]
}
