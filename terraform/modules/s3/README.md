# S3 Module

This module creates and configures an S3 bucket for file storage in the Cloud Tools application.

## Features

- **Secure by default**: Public access blocked, encryption enabled
- **Versioning**: Optional versioning support for file history
- **Lifecycle management**: Automatic cleanup and cost optimization
- **Intelligent tiering**: Automatic cost optimization based on access patterns
- **Cross-region replication**: Ready for multi-region setup (optional)

## Usage

```hcl
module "s3" {
  source = "./modules/s3"

  project_name          = "cloud-tools"
  environment           = "dev"
  resource_suffix       = "a1b2c3d4"
  enable_versioning     = true
  lifecycle_expiration_days = 30

  tags = {
    Project     = "cloud-tools"
    Environment = "dev"
    Owner       = "team"
  }
}
```

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.0  |
| aws       | ~> 5.0  |

## Providers

| Name | Version |
| ---- | ------- |
| aws  | ~> 5.0  |

## Resources

| Name                                                                                                                                                                                  | Type     |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_s3_bucket.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                                           | resource |
| [aws_s3_bucket_versioning.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning)                                                     | resource |
| [aws_s3_bucket_server_side_encryption_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_public_access_block.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block)                                   | resource |
| [aws_s3_bucket_lifecycle_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration)                           | resource |
| [aws_s3_bucket_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy)                                                             | resource |
| [aws_s3_bucket_intelligent_tiering_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_intelligent_tiering_configuration)       | resource |

## Inputs

| Name                      | Description                                    | Type          | Default         | Required |
| ------------------------- | ---------------------------------------------- | ------------- | --------------- | :------: |
| project_name              | Name of the project                            | `string`      | n/a             |   yes    |
| environment               | Environment name                               | `string`      | n/a             |   yes    |
| resource_suffix           | Random suffix for resource naming              | `string`      | n/a             |   yes    |
| bucket_prefix             | Prefix for S3 bucket name                      | `string`      | `"cloud-tools"` |    no    |
| enable_versioning         | Enable S3 bucket versioning                    | `bool`        | `true`          |    no    |
| lifecycle_expiration_days | Number of days after which objects are expired | `number`      | `30`            |    no    |
| tags                      | Tags to apply to resources                     | `map(string)` | `{}`            |    no    |

## Outputs

| Name                        | Description                           |
| --------------------------- | ------------------------------------- |
| bucket_name                 | Name of the S3 bucket                 |
| bucket_id                   | ID of the S3 bucket                   |
| bucket_arn                  | ARN of the S3 bucket                  |
| bucket_domain_name          | Domain name of the S3 bucket          |
| bucket_regional_domain_name | Regional domain name of the S3 bucket |
| bucket_region               | Region of the S3 bucket               |

## Security Features

- **Encryption at rest**: AES256 server-side encryption
- **Public access blocked**: All public access is denied
- **Secure transport**: HTTPS-only policy enforced
- **Access logging**: Ready for CloudTrail integration

## Cost Optimization

- **Intelligent tiering**: Automatic movement between storage classes
- **Lifecycle policies**: Automatic cleanup of old versions and incomplete uploads
- **Storage class transitions**: Standard → IA → Glacier progression

## Examples

### Basic Usage

```hcl
module "s3_basic" {
  source = "./modules/s3"

  project_name    = "my-project"
  environment     = "dev"
  resource_suffix = "abc123"
}
```

### Production Configuration

```hcl
module "s3_production" {
  source = "./modules/s3"

  project_name              = "my-project"
  environment               = "production"
  resource_suffix           = "def456"
  enable_versioning         = true
  lifecycle_expiration_days = 90

  tags = {
    Environment = "production"
    CostCenter  = "engineering"
    Backup      = "required"
  }
}
```
