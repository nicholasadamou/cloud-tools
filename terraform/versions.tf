terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }

  # Backend configuration will be provided by environment-specific configs
  # See environments/*/backend.tf for specific backend configurations
}

# Default provider configuration
# Region and other settings can be overridden by environment-specific configurations
provider "aws" {
  # Configuration will be provided via environment variables or AWS CLI profile
  default_tags {
    tags = {
      Project     = "cloud-tools"
      Environment = var.environment
      ManagedBy   = "terraform"
      Repository  = "github.com/nicholasadamou/cloud-tools"
    }
  }
}
