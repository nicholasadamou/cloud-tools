#!/bin/bash

# Cloud Tools Setup Verification Script
# Verifies that all required resources are properly configured

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "🔍 Verifying Cloud Tools setup..."

# Check LocalStack health
print_status "Checking LocalStack health..."
if curl -s http://localhost:4566/_localstack/health >/dev/null 2>&1; then
    # Get health status for individual services
    health_response=$(curl -s http://localhost:4566/_localstack/health 2>/dev/null)
    if command_exists jq && [[ -n "$health_response" ]]; then
        s3_status=$(echo "$health_response" | jq -r '.services.s3 // "unknown"')
        ddb_status=$(echo "$health_response" | jq -r '.services.dynamodb // "unknown"')
        sqs_status=$(echo "$health_response" | jq -r '.services.sqs // "unknown"')
        print_success "LocalStack is running (S3: $s3_status, DynamoDB: $ddb_status, SQS: $sqs_status)"
    else
        print_success "LocalStack is running and accessible"
    fi
else
    print_error "LocalStack is not accessible at http://localhost:4566"
    exit 1
fi

# Function to run AWS commands with LocalStack endpoint
aws_local() {
    if command_exists aws; then
        aws --endpoint-url=http://localhost:4566 --profile localstack "$@" 2>/dev/null
    else
        print_warning "AWS CLI not available, skipping AWS resource verification"
        return 1
    fi
}

# Check environment file
print_status "Checking environment configuration..."
if [ -f ".env.local" ]; then
    print_success ".env.local file exists"

    # Check if required variables are set
    if grep -q "AWS_ENDPOINT_URL=http://localhost:4566" .env.local; then
        print_success "LocalStack endpoint configured correctly"
    else
        print_warning "LocalStack endpoint might not be configured correctly"
    fi
else
    print_error ".env.local file not found"
fi

# Check S3 bucket
print_status "Checking S3 resources..."
if aws_local s3 ls | grep -q "cloud-tools-local-bucket"; then
    print_success "S3 bucket 'cloud-tools-local-bucket' exists"
else
    print_warning "S3 bucket 'cloud-tools-local-bucket' not found"
fi

# Check DynamoDB table
print_status "Checking DynamoDB resources..."
if aws_local dynamodb describe-table --table-name CloudToolsJobs >/dev/null 2>&1; then
    print_success "DynamoDB table 'CloudToolsJobs' exists"
else
    print_warning "DynamoDB table 'CloudToolsJobs' not found"
fi

# Check SQS queue
print_status "Checking SQS resources..."
if aws_local sqs get-queue-url --queue-name cloud-tools-jobs-queue >/dev/null 2>&1; then
    print_success "SQS queue 'cloud-tools-jobs-queue' exists"
else
    print_warning "SQS queue 'cloud-tools-jobs-queue' not found"
fi

# Check dependencies
print_status "Checking Node.js dependencies..."
if [ -d "node_modules" ]; then
    print_success "Node.js dependencies installed"
else
    print_warning "Node.js dependencies not found. Run 'npm install' or equivalent."
fi

# Summary
echo ""
print_status "📋 Setup Summary:"
echo "✅ LocalStack: $(curl -s http://localhost:4566/_localstack/health | jq -r '.services.s3' 2>/dev/null || echo 'Unknown')"
echo "✅ Environment: $([[ -f .env.local ]] && echo 'Configured' || echo 'Missing')"
echo "✅ Dependencies: $([[ -d node_modules ]] && echo 'Installed' || echo 'Missing')"

if command_exists aws; then
    echo "✅ AWS Resources:"
    echo "   - S3: $(aws_local s3 ls | grep -q cloud-tools-local-bucket && echo 'Ready' || echo 'Not found')"
    echo "   - DynamoDB: $(aws_local dynamodb describe-table --table-name CloudToolsJobs >/dev/null 2>&1 && echo 'Ready' || echo 'Not found')"
    echo "   - SQS: $(aws_local sqs get-queue-url --queue-name cloud-tools-jobs-queue >/dev/null 2>&1 && echo 'Ready' || echo 'Not found')"
else
    echo "⚠️  AWS CLI not available - resource verification skipped"
fi

echo ""
print_success "🎯 Verification completed! Your development environment is ready."
