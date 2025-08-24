# API Gateway Module

This Terraform module creates an AWS API Gateway REST API with Lambda integrations for the Cloud Tools project. It sets up endpoints for file conversion and compression operations with proper CORS handling and CloudWatch logging.

## Features

- **REST API Gateway**: Regional API Gateway with proper naming and tagging
- **Multiple Endpoints**: `/convert`, `/compress`, and `/jobs` resources
- **Lambda Integration**: AWS_PROXY integration with Lambda functions
- **CORS Support**: Full CORS handling with OPTIONS method responses
- **Access Logging**: CloudWatch logs for API Gateway access patterns
- **Security**: Lambda function permissions and optional WAF integration
- **Stage Management**: Deployment and stage configuration

## Resources Created

### API Gateway Resources
- `aws_api_gateway_rest_api.main` - The main REST API
- `aws_api_gateway_resource.convert` - Convert endpoint resource
- `aws_api_gateway_resource.compress` - Compress endpoint resource  
- `aws_api_gateway_resource.jobs` - Jobs endpoint resource
- `aws_api_gateway_deployment.main` - API deployment
- `aws_api_gateway_stage.main` - API stage with access logging

### Methods and Integrations
- POST methods for `/convert` and `/compress` endpoints
- OPTIONS methods for CORS preflight requests
- Lambda proxy integrations for business logic
- MOCK integrations for CORS responses

### Permissions and Logging
- Lambda permissions for API Gateway invocation
- CloudWatch log group for access logs
- Proper response headers for CORS compliance

## Usage

### Basic Usage

```hcl
module "api_gateway" {
  source = "./modules/api-gateway"

  project_name             = "cloud-tools"
  environment             = "production"
  resource_suffix         = "abc123"
  convert_lambda_arn      = module.lambda.convert_lambda_arn
  compress_lambda_arn     = module.lambda.compress_lambda_arn
  process_lambda_arn      = module.lambda.process_lambda_arn
  convert_lambda_name     = module.lambda.convert_lambda_name
  compress_lambda_name    = module.lambda.compress_lambda_name
  process_lambda_name     = module.lambda.process_lambda_name

  tags = {
    Environment = "production"
    Owner       = "platform-team"
    Project     = "cloud-tools"
  }
}
```

### Advanced Configuration

```hcl
module "api_gateway" {
  source = "./modules/api-gateway"

  project_name             = "cloud-tools"
  environment             = "production"
  resource_suffix         = "abc123"
  
  # Lambda function configuration
  convert_lambda_arn      = module.lambda.convert_lambda_arn
  compress_lambda_arn     = module.lambda.compress_lambda_arn
  process_lambda_arn      = module.lambda.process_lambda_arn
  convert_lambda_name     = module.lambda.convert_lambda_name
  compress_lambda_name    = module.lambda.compress_lambda_name
  process_lambda_name     = module.lambda.process_lambda_name
  
  # CORS configuration
  allowed_cors_origins = [
    "https://myapp.example.com",
    "https://staging.example.com"
  ]
  
  # Security settings
  enable_waf = true
  
  # Resource tagging
  tags = {
    Environment   = "production"
    Owner         = "platform-team"
    Project       = "cloud-tools"
    CostCenter    = "engineering"
    Backup        = "daily"
  }
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_name` | Name of the project | `string` | n/a | yes |
| `environment` | Environment name | `string` | n/a | yes |
| `resource_suffix` | Random suffix for resource naming | `string` | n/a | yes |
| `convert_lambda_arn` | ARN of the convert Lambda function | `string` | n/a | yes |
| `compress_lambda_arn` | ARN of the compress Lambda function | `string` | n/a | yes |
| `process_lambda_arn` | ARN of the process Lambda function | `string` | n/a | yes |
| `convert_lambda_name` | Name of the convert Lambda function | `string` | n/a | yes |
| `compress_lambda_name` | Name of the compress Lambda function | `string` | n/a | yes |
| `process_lambda_name` | Name of the process Lambda function | `string` | n/a | yes |
| `allowed_cors_origins` | List of allowed CORS origins | `list(string)` | `["*"]` | no |
| `enable_waf` | Enable AWS WAF for API Gateway | `bool` | `true` | no |
| `tags` | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `api_gateway_url` | URL of the API Gateway |
| `api_gateway_id` | ID of the API Gateway |
| `stage_name` | Name of the API Gateway stage |

## API Endpoints

The module creates the following API endpoints:

### POST /convert
- **Purpose**: File conversion operations
- **Integration**: AWS_PROXY with convert Lambda function
- **CORS**: Enabled with OPTIONS preflight

### POST /compress  
- **Purpose**: File compression operations
- **Integration**: AWS_PROXY with compress Lambda function
- **CORS**: Enabled with OPTIONS preflight

### /jobs
- **Purpose**: Job status and management (resource created for future use)
- **Integration**: To be configured with process Lambda function

## Access Logging

The API Gateway is configured with structured JSON access logs that capture:

- `requestId` - Unique request identifier
- `ip` - Source IP address
- `caller` - Identity caller information
- `user` - User information
- `requestTime` - Timestamp of the request
- `httpMethod` - HTTP method used
- `resourcePath` - Resource path accessed
- `status` - HTTP response status
- `protocol` - Protocol version
- `responseLength` - Size of the response

Logs are stored in CloudWatch with a 14-day retention period.

## Security Considerations

1. **Lambda Permissions**: Each Lambda function receives specific permissions to be invoked by API Gateway
2. **CORS Configuration**: Origins can be restricted using the `allowed_cors_origins` variable
3. **WAF Integration**: Optional WAF protection can be enabled (currently configured as variable, implementation pending)
4. **Regional Endpoint**: Uses regional endpoint type for better performance and security

## Dependencies

This module depends on:
- Lambda functions being created first (for ARN and name references)
- Proper IAM roles for Lambda execution
- CloudWatch service availability for logging

## Cost Optimization

- **Log Retention**: CloudWatch logs are retained for 14 days to balance observability and cost
- **Regional Deployment**: Uses regional endpoints to minimize data transfer costs
- **Stage Management**: Single stage deployment reduces resource overhead

## Monitoring and Observability

The module provides comprehensive monitoring through:
- CloudWatch access logs with structured JSON format
- API Gateway metrics (automatically available)
- Integration with Lambda function metrics
- Request/response logging for debugging

## Migration Notes

When upgrading or migrating this module:
1. Review lambda function references to ensure ARNs and names are correct
2. Verify CORS origins match your application requirements
3. Check CloudWatch log retention policies
4. Ensure proper dependency ordering in your Terraform configuration

## Examples

### Development Environment
```hcl
module "api_gateway_dev" {
  source = "./modules/api-gateway"

  project_name      = "cloud-tools"
  environment      = "dev"
  resource_suffix  = random_id.suffix.hex
  
  convert_lambda_arn   = module.lambda_dev.convert_lambda_arn
  compress_lambda_arn  = module.lambda_dev.compress_lambda_arn
  process_lambda_arn   = module.lambda_dev.process_lambda_arn
  convert_lambda_name  = module.lambda_dev.convert_lambda_name
  compress_lambda_name = module.lambda_dev.compress_lambda_name  
  process_lambda_name  = module.lambda_dev.process_lambda_name
  
  # Development-specific settings
  allowed_cors_origins = ["http://localhost:3000", "http://localhost:8080"]
  enable_waf          = false
  
  tags = {
    Environment = "development"
    Project     = "cloud-tools"
    ManagedBy   = "terraform"
  }
}
```

### Production Environment with Custom CORS
```hcl
module "api_gateway_prod" {
  source = "./modules/api-gateway"

  project_name      = "cloud-tools"
  environment      = "production"
  resource_suffix  = random_id.suffix.hex
  
  convert_lambda_arn   = module.lambda_prod.convert_lambda_arn
  compress_lambda_arn  = module.lambda_prod.compress_lambda_arn
  process_lambda_arn   = module.lambda_prod.process_lambda_arn
  convert_lambda_name  = module.lambda_prod.convert_lambda_name
  compress_lambda_name = module.lambda_prod.compress_lambda_name
  process_lambda_name  = module.lambda_prod.process_lambda_name
  
  # Production-specific settings
  allowed_cors_origins = [
    "https://app.cloudtools.com",
    "https://admin.cloudtools.com"
  ]
  enable_waf = true
  
  tags = {
    Environment = "production"
    Project     = "cloud-tools"
    Owner       = "platform-team"
    Backup      = "daily"
    ManagedBy   = "terraform"
  }
}
```
