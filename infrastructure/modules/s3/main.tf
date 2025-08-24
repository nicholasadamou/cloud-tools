terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.0"
      configuration_aliases = [aws.replica]
    }
  }
}

# S3 bucket for file storage
resource "aws_s3_bucket" "main" {
  bucket = "${var.bucket_prefix}-${var.environment}-${var.resource_suffix}"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-bucket"
    Type = "FileStorage"
  })
}

# S3 bucket versioning configuration
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# S3 bucket encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_id
    }
    bucket_key_enabled = true
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "cleanup_expired_files"
    status = "Enabled"

    filter {
      prefix = ""
    }

    # Delete old file versions
    noncurrent_version_expiration {
      noncurrent_days = 7
    }

    # Delete incomplete multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    # Move files to different storage classes
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    # Delete old files
    expiration {
      days = var.lifecycle_expiration_days
    }
  }

  # Separate rule for processed files (shorter retention)
  rule {
    id     = "processed_files_cleanup"
    status = "Enabled"

    filter {
      prefix = "processed/"
    }

    expiration {
      days = 7
    }

    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }
}

# CKV2_AWS_62: Ensure S3 buckets should have event notifications enabled
# S3 bucket notification configuration (for SQS integration)
resource "aws_s3_bucket_notification" "main" {
  bucket = aws_s3_bucket.main.id

  # Default CloudWatch metrics notification to ensure compliance
  eventbridge = true

  # This will be populated by the SQS module for additional notifications
  depends_on = [aws_s3_bucket.main]
}

# S3 bucket policy for Lambda access
resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureConnections"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.main.arn,
          "${aws_s3_bucket.main.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# CloudWatch metrics for S3 bucket
resource "aws_s3_bucket_metric" "main" {
  bucket = aws_s3_bucket.main.id
  name   = "EntireBucket"
}

# S3 bucket intelligent tiering configuration
resource "aws_s3_bucket_intelligent_tiering_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  name   = "EntireBucket"

  status = "Enabled"

  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = 90
  }

  tiering {
    access_tier = "DEEP_ARCHIVE_ACCESS"
    days        = 180
  }
}

# CKV_AWS_18: S3 access logging bucket
resource "aws_s3_bucket" "access_logs" {
  count  = var.environment == "production" ? 1 : 0
  bucket = "${var.bucket_prefix}-${var.environment}-access-logs-${var.resource_suffix}"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-access-logs-bucket"
    Type = "AccessLogs"
  })
}

# CKV_AWS_21: Ensure all data stored in the S3 bucket have versioning enabled
resource "aws_s3_bucket_versioning" "access_logs" {
  count  = var.environment == "production" ? 1 : 0
  bucket = aws_s3_bucket.access_logs[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  count  = var.environment == "production" ? 1 : 0
  bucket = aws_s3_bucket.access_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  count  = var.environment == "production" ? 1 : 0
  bucket = aws_s3_bucket.access_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_id
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
  count  = var.environment == "production" ? 1 : 0
  bucket = aws_s3_bucket.access_logs[0].id

  rule {
    id     = "access_logs_cleanup"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = 90
    }

    # CKV_AWS_300: Ensure S3 lifecycle configuration sets period for aborting failed uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# CKV2_AWS_62: Event notifications for access_logs bucket
resource "aws_s3_bucket_notification" "access_logs" {
  count  = var.environment == "production" ? 1 : 0
  bucket = aws_s3_bucket.access_logs[0].id

  eventbridge = true
}

# Create a separate bucket for access logs of the access_logs bucket to avoid circular dependency
resource "aws_s3_bucket" "access_logs_logs" {
  count  = var.environment == "production" ? 1 : 0
  bucket = "${var.bucket_prefix}-${var.environment}-access-logs-logs-${var.resource_suffix}"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-access-logs-logs-bucket"
    Type = "AccessLogsLogs"
  })
}

resource "aws_s3_bucket_public_access_block" "access_logs_logs" {
  count  = var.environment == "production" ? 1 : 0
  bucket = aws_s3_bucket.access_logs_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "access_logs_logs" {
  count  = var.environment == "production" ? 1 : 0
  bucket = aws_s3_bucket.access_logs_logs[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs_logs" {
  count  = var.environment == "production" ? 1 : 0
  bucket = aws_s3_bucket.access_logs_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_id
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs_logs" {
  count  = var.environment == "production" ? 1 : 0
  bucket = aws_s3_bucket.access_logs_logs[0].id

  rule {
    id     = "access_logs_logs_cleanup"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = 30 # Shorter retention for logs of logs
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_notification" "access_logs_logs" {
  count  = var.environment == "production" ? 1 : 0
  bucket = aws_s3_bucket.access_logs_logs[0].id

  eventbridge = true
}

# S3 access logging configuration for main bucket
resource "aws_s3_bucket_logging" "main" {
  count  = var.environment == "production" ? 1 : 0
  bucket = aws_s3_bucket.main.id

  target_bucket = aws_s3_bucket.access_logs[0].id
  target_prefix = "access-logs/"

  depends_on = [aws_s3_bucket_public_access_block.access_logs]
}

# S3 access logging configuration for access_logs bucket
resource "aws_s3_bucket_logging" "access_logs" {
  count  = var.environment == "production" ? 1 : 0
  bucket = aws_s3_bucket.access_logs[0].id

  target_bucket = aws_s3_bucket.access_logs_logs[0].id
  target_prefix = "access-logs-logs/"

  depends_on = [aws_s3_bucket_public_access_block.access_logs_logs]
}

# S3 access logging configuration for replica bucket
resource "aws_s3_bucket_logging" "replica" {
  count    = var.environment == "production" ? 1 : 0
  provider = aws.replica
  bucket   = aws_s3_bucket.replica[0].id

  target_bucket = aws_s3_bucket.access_logs[0].id
  target_prefix = "replica-logs/"

  depends_on = [aws_s3_bucket_public_access_block.access_logs]
}

# CKV_AWS_144: Cross-region replication for production
resource "aws_s3_bucket" "replica" {
  count    = var.environment == "production" ? 1 : 0
  provider = aws.replica
  bucket   = "${var.bucket_prefix}-${var.environment}-replica-${var.resource_suffix}"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-replica-bucket"
    Type = "ReplicaBucket"
  })
}

resource "aws_s3_bucket_versioning" "replica" {
  count    = var.environment == "production" ? 1 : 0
  provider = aws.replica
  bucket   = aws_s3_bucket.replica[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# CKV_AWS_145: Ensure that S3 buckets are encrypted with KMS by default
resource "aws_s3_bucket_server_side_encryption_configuration" "replica" {
  count    = var.environment == "production" ? 1 : 0
  provider = aws.replica
  bucket   = aws_s3_bucket.replica[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_id
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "replica" {
  count    = var.environment == "production" ? 1 : 0
  provider = aws.replica
  bucket   = aws_s3_bucket.replica[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CKV2_AWS_61: Lifecycle configuration for replica bucket
resource "aws_s3_bucket_lifecycle_configuration" "replica" {
  count    = var.environment == "production" ? 1 : 0
  provider = aws.replica
  bucket   = aws_s3_bucket.replica[0].id

  rule {
    id     = "replica_cleanup"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = var.lifecycle_expiration_days
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }

    # CKV_AWS_300: Ensure S3 lifecycle configuration sets period for aborting failed uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# CKV2_AWS_62: Event notifications for replica bucket
resource "aws_s3_bucket_notification" "replica" {
  count    = var.environment == "production" ? 1 : 0
  provider = aws.replica
  bucket   = aws_s3_bucket.replica[0].id

  eventbridge = true
}

# IAM role for S3 replication
resource "aws_iam_role" "replication" {
  count = var.environment == "production" ? 1 : 0
  name  = "${var.project_name}-${var.environment}-s3-replication-role-${var.resource_suffix}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-s3-replication-role"
    Type = "S3ReplicationRole"
  })
}

resource "aws_iam_role_policy" "replication" {
  count = var.environment == "production" ? 1 : 0
  name  = "${var.project_name}-${var.environment}-s3-replication-policy-${var.resource_suffix}"
  role  = aws_iam_role.replication[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.main.arn
        ]
      },
      {
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.main.arn}/*"
        ]
      },
      {
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.replica[0].arn}/*"
        ]
      }
    ]
  })
}

# S3 replication configuration
resource "aws_s3_bucket_replication_configuration" "main" {
  count      = var.environment == "production" ? 1 : 0
  depends_on = [aws_s3_bucket_versioning.main]

  role   = aws_iam_role.replication[0].arn
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "replicate_all"
    status = "Enabled"

    filter {
      prefix = ""
    }

    destination {
      bucket        = aws_s3_bucket.replica[0].arn
      storage_class = "STANDARD_IA"
    }
  }
}
