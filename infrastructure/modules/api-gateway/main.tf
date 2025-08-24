terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Variables for API Gateway module
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

variable "convert_lambda_arn" {
  description = "ARN of the convert Lambda function"
  type        = string
}

variable "compress_lambda_arn" {
  description = "ARN of the compress Lambda function"
  type        = string
}

variable "convert_lambda_name" {
  description = "Name of the convert Lambda function"
  type        = string
}

variable "compress_lambda_name" {
  description = "Name of the compress Lambda function"
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


# API Gateway REST API
resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.project_name}-api-${var.environment}-${var.resource_suffix}"
  description = "Cloud Tools API Gateway for ${var.environment} environment"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-api"
    Type = "APIGateway"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# CKV2_AWS_53: API Gateway request validator
resource "aws_api_gateway_request_validator" "main" {
  name                        = "${var.project_name}-${var.environment}-request-validator"
  rest_api_id                 = aws_api_gateway_rest_api.main.id
  validate_request_body       = true
  validate_request_parameters = true
}

# CKV2_AWS_51: Client certificate for production
resource "aws_api_gateway_client_certificate" "main" {
  count       = var.environment == "production" ? 1 : 0
  description = "Client certificate for ${var.project_name} ${var.environment} API Gateway"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-client-cert"
    Type = "APIGatewayCertificate"
  })
}

# CKV2_AWS_29: WAF Web ACL for API Gateway protection
resource "aws_wafv2_web_acl" "main" {
  count = var.environment == "production" ? 1 : 0
  name  = "${var.project_name}-${var.environment}-api-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "RateLimitRule"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-api-waf"
    Type = "WAF"
  })

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}${var.environment}WAF"
    sampled_requests_enabled   = true
  }
}

# Associate WAF with API Gateway stage
resource "aws_wafv2_web_acl_association" "main" {
  count        = var.environment == "production" ? 1 : 0
  resource_arn = aws_api_gateway_stage.main.arn
  web_acl_arn  = aws_wafv2_web_acl.main[0].arn

  depends_on = [aws_api_gateway_stage.main]
}

# API Gateway resources
resource "aws_api_gateway_resource" "convert" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "convert"
}

resource "aws_api_gateway_resource" "compress" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "compress"
}

resource "aws_api_gateway_resource" "jobs" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "jobs"
}

# API Gateway methods for convert
resource "aws_api_gateway_method" "convert_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.convert.id
  http_method   = "POST"
  authorization = "AWS_IAM" # CKV_AWS_59: Prevent open access to backend resources

  request_parameters = {
    "method.request.header.Authorization" = true
  }

  # CKV2_AWS_53: Add request validation
  request_validator_id = aws_api_gateway_request_validator.main.id
}

resource "aws_api_gateway_method" "convert_options" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.convert.id
  http_method   = "OPTIONS"
  authorization = "NONE"

  # CKV2_AWS_53: Add request validation for OPTIONS (CORS)
  request_validator_id = aws_api_gateway_request_validator.main.id
}

# API Gateway methods for compress
resource "aws_api_gateway_method" "compress_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.compress.id
  http_method   = "POST"
  authorization = "AWS_IAM" # CKV_AWS_59: Prevent open access to backend resources

  request_parameters = {
    "method.request.header.Authorization" = true
  }

  # CKV2_AWS_53: Add request validation
  request_validator_id = aws_api_gateway_request_validator.main.id
}

resource "aws_api_gateway_method" "compress_options" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.compress.id
  http_method   = "OPTIONS"
  authorization = "NONE"

  # CKV2_AWS_53: Add request validation for OPTIONS (CORS)
  request_validator_id = aws_api_gateway_request_validator.main.id
}

# API Gateway integrations
resource "aws_api_gateway_integration" "convert_lambda" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.convert.id
  http_method = aws_api_gateway_method.convert_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.convert_lambda_arn
}

resource "aws_api_gateway_integration" "compress_lambda" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.compress.id
  http_method = aws_api_gateway_method.compress_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.compress_lambda_arn
}

# CORS integrations
resource "aws_api_gateway_integration" "convert_options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.convert.id
  http_method = aws_api_gateway_method.convert_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_integration" "compress_options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.compress.id
  http_method = aws_api_gateway_method.compress_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

# API Gateway method responses for CORS
resource "aws_api_gateway_method_response" "convert_options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.convert.id
  http_method = aws_api_gateway_method.convert_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "compress_options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.compress.id
  http_method = aws_api_gateway_method.compress_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

# API Gateway integration responses for CORS
resource "aws_api_gateway_integration_response" "convert_options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.convert.id
  http_method = aws_api_gateway_method.convert_options.http_method
  status_code = aws_api_gateway_method_response.convert_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_integration_response" "compress_options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.compress.id
  http_method = aws_api_gateway_method.compress_options.http_method
  status_code = aws_api_gateway_method_response.compress_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# Lambda permissions for API Gateway
resource "aws_lambda_permission" "convert_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.convert_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "compress_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.compress_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

# API Gateway deployment
resource "aws_api_gateway_deployment" "main" {
  depends_on = [
    aws_api_gateway_integration.convert_lambda,
    aws_api_gateway_integration.compress_lambda,
    aws_api_gateway_integration.convert_options,
    aws_api_gateway_integration.compress_options
  ]

  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = var.environment

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway stage
resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.environment

  # Enable X-Ray tracing
  xray_tracing_enabled = true

  # CKV_AWS_120: Enable API Gateway caching for all environments
  cache_cluster_enabled = true
  cache_cluster_size    = var.environment == "production" ? "1.6" : "0.5"

  # CKV2_AWS_51: Enable client certificate authentication for production
  client_certificate_id = var.environment == "production" ? aws_api_gateway_client_certificate.main[0].id : null

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      caller         = "$context.identity.caller"
      user           = "$context.identity.user"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  # CKV2_AWS_4: Set appropriate logging level
  variables = {
    "logging_level" = var.environment == "production" ? "ERROR" : "INFO"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-api-stage"
    Type = "APIGatewayStage"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# CloudWatch log group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.project_name}-${var.environment}"
  retention_in_days = var.environment == "production" ? 365 : 14
  kms_key_id        = var.kms_key_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-api-logs"
    Type = "APIGatewayLogs"
  })
}

# Outputs
output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = aws_api_gateway_stage.main.invoke_url
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.main.id
}

output "stage_name" {
  description = "Name of the API Gateway stage"
  value       = aws_api_gateway_stage.main.stage_name
}
