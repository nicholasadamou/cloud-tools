# Build TypeScript Lambda deployment packages
# This uses our enhanced build script to create production-ready packages
resource "null_resource" "build_lambda_packages" {
  triggers = {
    # Rebuild when source files change
    handlers_hash = filemd5("${path.module}/src/handlers/convert.ts")
    adapter_hash  = filemd5("${path.module}/src/adapters/aws-lambda-adapter.ts")
    build_script  = filemd5("${path.module}/build.sh")
  }

  provisioner "local-exec" {
    command     = "./build.sh"
    working_dir = path.module
  }
}

# Use the built ZIP packages directly
locals {
  convert_lambda_path  = "${path.module}/.build/lambda/convert-lambda.zip"
  compress_lambda_path = "${path.module}/.build/lambda/compress-lambda.zip"
  process_lambda_path  = "${path.module}/.build/lambda/process-lambda.zip"
}

# Convert Lambda function
resource "aws_lambda_function" "convert" {
  filename         = local.convert_lambda_path
  function_name    = "${var.project_name}-convert-${var.environment}-${var.resource_suffix}"
  role             = var.lambda_execution_role_arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256(local.convert_lambda_path)
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  depends_on = [null_resource.build_lambda_packages]

  environment {
    variables = merge(var.environment_variables, {
      FUNCTION_NAME = "convert"
    })
  }

  # Enable X-Ray tracing for performance monitoring
  tracing_config {
    mode = var.environment == "production" ? "Active" : "PassThrough"
  }

  # Enable dead letter queue configuration
  dead_letter_config {
    target_arn = replace(var.environment_variables["SQS_QUEUE_URL"], "cloud-tools-jobs-queue", "cloud-tools-jobs-queue-dlq")
  }

  tags = merge(var.tags, {
    Name     = "${var.project_name}-${var.environment}-convert-function"
    Type     = "FileConversion"
    Function = "convert"
  })
}

# Compress Lambda function
resource "aws_lambda_function" "compress" {
  filename         = local.compress_lambda_path
  function_name    = "${var.project_name}-compress-${var.environment}-${var.resource_suffix}"
  role             = var.lambda_execution_role_arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256(local.compress_lambda_path)
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  depends_on = [null_resource.build_lambda_packages]

  environment {
    variables = merge(var.environment_variables, {
      FUNCTION_NAME = "compress"
    })
  }

  tracing_config {
    mode = var.environment == "production" ? "Active" : "PassThrough"
  }

  dead_letter_config {
    target_arn = replace(var.environment_variables["SQS_QUEUE_URL"], "cloud-tools-jobs-queue", "cloud-tools-jobs-queue-dlq")
  }

  tags = merge(var.tags, {
    Name     = "${var.project_name}-${var.environment}-compress-function"
    Type     = "FileCompression"
    Function = "compress"
  })
}

# Process Lambda function (for SQS processing)
resource "aws_lambda_function" "process" {
  filename         = local.process_lambda_path
  function_name    = "${var.project_name}-process-${var.environment}-${var.resource_suffix}"
  role             = var.lambda_execution_role_arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256(local.process_lambda_path)
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  depends_on = [null_resource.build_lambda_packages]

  environment {
    variables = merge(var.environment_variables, {
      FUNCTION_NAME = "process"
    })
  }

  tracing_config {
    mode = var.environment == "production" ? "Active" : "PassThrough"
  }

  dead_letter_config {
    target_arn = replace(var.environment_variables["SQS_QUEUE_URL"], "cloud-tools-jobs-queue", "cloud-tools-jobs-queue-dlq")
  }

  tags = merge(var.tags, {
    Name     = "${var.project_name}-${var.environment}-process-function"
    Type     = "FileProcessing"
    Function = "process"
  })
}

# CloudWatch log groups for Lambda functions
resource "aws_cloudwatch_log_group" "convert" {
  name              = "/aws/lambda/${aws_lambda_function.convert.function_name}"
  retention_in_days = 14

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-convert-logs"
  })
}

resource "aws_cloudwatch_log_group" "compress" {
  name              = "/aws/lambda/${aws_lambda_function.compress.function_name}"
  retention_in_days = 14

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-compress-logs"
  })
}

resource "aws_cloudwatch_log_group" "process" {
  name              = "/aws/lambda/${aws_lambda_function.process.function_name}"
  retention_in_days = 14

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-process-logs"
  })
}
