terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
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

# S3 bucket notification configuration (for SQS integration)
resource "aws_s3_bucket_notification" "main" {
  bucket = aws_s3_bucket.main.id

  # This will be populated by the SQS module
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
