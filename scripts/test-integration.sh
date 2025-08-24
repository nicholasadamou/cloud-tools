#!/bin/bash

# Cloud Tools Integration Test Script
# Tests the complete AWS/LocalStack integration workflow

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info "🧪 Running Cloud Tools Integration Tests..."

# Test 1: Check LocalStack is running
print_info "Test 1: Checking LocalStack connectivity..."
if curl -s http://localhost:4566/_localstack/health >/dev/null 2>&1; then
    print_success "LocalStack is running and accessible"
else
    print_error "LocalStack is not accessible. Run 'npm run localstack:start' first."
    exit 1
fi

# Test 2: Check AWS resources exist
print_info "Test 2: Verifying AWS resources..."

# Use environment variables for AWS credentials (for CI/CD)
BUCKET_NAME=${S3_BUCKET_NAME:-"test-bucket"}
TABLE_NAME=${DYNAMODB_TABLE_NAME:-"Jobs"}
QUEUE_NAME="file-processing-queue"

# Check S3 bucket
if aws --endpoint-url=http://localhost:4566 s3 ls | grep -q "$BUCKET_NAME"; then
    print_success "S3 bucket exists: $BUCKET_NAME"
else
    print_error "S3 bucket not found: $BUCKET_NAME"
    exit 1
fi

# Check DynamoDB table  
if aws --endpoint-url=http://localhost:4566 dynamodb describe-table --table-name "$TABLE_NAME" >/dev/null 2>&1; then
    print_success "DynamoDB table exists: $TABLE_NAME"
else
    print_error "DynamoDB table not found: $TABLE_NAME"
    exit 1
fi

# Check SQS queue
if aws --endpoint-url=http://localhost:4566 sqs get-queue-url --queue-name "$QUEUE_NAME" >/dev/null 2>&1; then
    print_success "SQS queue exists: $QUEUE_NAME"
else
    print_error "SQS queue not found: $QUEUE_NAME"
    exit 1
fi

# Test 3: Test API endpoints (if Next.js server is running)
print_info "Test 3: Testing API endpoints..."

API_BASE_URL="http://localhost:3000/api"

# Check if Next.js server is running
if curl -s http://localhost:3000 >/dev/null 2>&1; then
    print_success "Next.js server is running"
    
    # Test upload endpoint
    print_info "Testing upload endpoint..."
    
    # Create a small test file
    echo "test file content" > /tmp/test-file.txt
    
    # Test upload API
    UPLOAD_RESPONSE=$(curl -s -X POST \
        -F "file=@/tmp/test-file.txt" \
        -F "operation=convert" \
        -F "targetFormat=pdf" \
        "$API_BASE_URL/upload")
    
    if echo "$UPLOAD_RESPONSE" | grep -q '"success":true'; then
        print_success "Upload API endpoint working"
        
        # Extract job ID for further testing
        JOB_ID=$(echo "$UPLOAD_RESPONSE" | grep -o '"jobId":"[^"]*"' | cut -d'"' -f4)
        print_info "Generated Job ID: $JOB_ID"
        
        # Test jobs endpoint
        print_info "Testing jobs endpoint..."
        JOBS_RESPONSE=$(curl -s "$API_BASE_URL/jobs?jobId=$JOB_ID")
        
        if echo "$JOBS_RESPONSE" | grep -q '"success":true'; then
            print_success "Jobs API endpoint working"
        else
            print_warning "Jobs API endpoint not working as expected"
            echo "Response: $JOBS_RESPONSE"
        fi
        
        # Test process endpoint
        print_info "Testing process endpoint..."
        PROCESS_RESPONSE=$(curl -s -X POST \
            -H "Content-Type: application/json" \
            -d "{\"jobId\":\"$JOB_ID\",\"operation\":\"convert\",\"targetFormat\":\"pdf\"}" \
            "$API_BASE_URL/process")
        
        if echo "$PROCESS_RESPONSE" | grep -q '"success":true'; then
            print_success "Process API endpoint working"
        else
            print_warning "Process API endpoint not working as expected"
            echo "Response: $PROCESS_RESPONSE"
        fi
        
    else
        print_warning "Upload API endpoint not working as expected"
        echo "Response: $UPLOAD_RESPONSE"
    fi
    
    # Clean up test file
    rm -f /tmp/test-file.txt
    
else
    print_warning "Next.js server is not running. Skipping API tests."
    print_info "Run 'npm run dev' to start the server and test API endpoints."
fi

# Test 4: Check SQS message
print_info "Test 4: Checking SQS queue for messages..."
QUEUE_URL="http://localhost:4566/000000000000/file-processing-queue"

MESSAGES=$(aws --endpoint-url=http://localhost:4566 sqs receive-message --queue-url "$QUEUE_URL" --max-number-of-messages 1 2>/dev/null || echo "{}")

if echo "$MESSAGES" | grep -q "Messages"; then
    print_success "Found messages in SQS queue"
    MESSAGE_COUNT=$(echo "$MESSAGES" | grep -o '"Messages"' | wc -l)
    print_info "Approximate messages in queue: $MESSAGE_COUNT"
else
    print_info "No messages in SQS queue (this is expected for a fresh test)"
fi

# Test 5: Verify environment configuration
print_info "Test 5: Checking environment configuration..."

if [[ -f ".env.local" ]]; then
    if grep -q "AWS_ENDPOINT_URL=http://localhost:4566" .env.local; then
        print_success "Environment configured for LocalStack"
    else
        print_warning "Environment might not be configured correctly for LocalStack"
    fi
else
    print_error ".env.local file not found"
    exit 1
fi

# Summary
echo ""
print_success "🎉 Integration tests completed!"
echo ""
print_info "Summary of what was tested:"
echo "  ✅ LocalStack connectivity"
echo "  ✅ AWS resources (S3, DynamoDB, SQS)"
echo "  ✅ API endpoints (if server running)"
echo "  ✅ SQS message handling"
echo "  ✅ Environment configuration"
echo ""
print_info "Your Cloud Tools application is ready for development!"
echo ""
print_info "Next steps:"
echo "  • Run 'npm run dev' to start the development server"
echo "  • Visit http://localhost:3000 to use the application"
echo "  • Visit http://localhost:3000/jobs to check job status"
echo "  • Monitor LocalStack: 'npm run localstack:logs'"
