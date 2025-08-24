#!/bin/bash

# Cloud Tools Development Setup Script
# This script sets up everything needed for local development

set -e

echo "🚀 Setting up Cloud Tools for local development..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check prerequisites
print_status "Checking prerequisites..."

if ! command_exists docker; then
    print_error "Docker is required but not installed. Please install Docker Desktop."
    exit 1
fi

if ! command_exists docker-compose && ! docker compose version >/dev/null 2>&1; then
    print_error "Docker Compose is required but not found. Please install Docker Compose."
    exit 1
fi

if ! command_exists node; then
    print_error "Node.js is required but not installed. Please install Node.js 18+."
    exit 1
fi

if ! command_exists aws; then
    print_warning "AWS CLI not found. Some features may not work properly."
    print_warning "Install AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
fi

print_success "Prerequisites check completed!"

# Create .env.local if it doesn't exist
print_status "Setting up environment configuration..."
if [ ! -f ".env.local" ]; then
    cp client/.env.local.example .env.local
    print_success "Created .env.local from client/.env.local.example"
else
    print_warning ".env.local already exists, skipping..."
fi

# Install dependencies
print_status "Installing dependencies..."
if command_exists pnpm; then
    pnpm install
elif command_exists yarn; then
    yarn install
else
    npm install
fi
print_success "Dependencies installed!"

# Start LocalStack
print_status "Starting LocalStack services..."
if docker ps --format 'table {{.Names}}' | grep -q "cloud-tools-localstack"; then
    print_warning "LocalStack container is already running"
else
    docker compose -f client/docker-compose.yml up -d
    print_success "LocalStack started!"
fi

# Wait for LocalStack to be ready
print_status "Waiting for LocalStack to be ready..."
max_attempts=30
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if curl -s http://localhost:4566/_localstack/health >/dev/null 2>&1; then
        print_success "LocalStack is ready!"
        break
    fi
    sleep 2
    attempt=$((attempt + 1))
    echo -n "."
done

if [ $attempt -eq $max_attempts ]; then
    print_error "LocalStack failed to start within timeout"
    exit 1
fi

# Configure AWS CLI profile if AWS CLI is available
if command_exists aws; then
    print_status "Configuring AWS CLI for LocalStack..."
    if ! aws configure list --profile localstack >/dev/null 2>&1; then
        print_status "Creating AWS profile for LocalStack..."
        aws configure set aws_access_key_id test --profile localstack
        aws configure set aws_secret_access_key test --profile localstack
        aws configure set region us-east-1 --profile localstack
        aws configure set output json --profile localstack
        print_success "AWS CLI profile 'localstack' created!"
    else
        print_warning "AWS CLI profile 'localstack' already exists"
    fi
fi

# Verify setup
print_status "Verifying setup..."
./scripts/verify-setup.sh

echo ""
print_success "🎉 Setup completed successfully!"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Run 'npm run dev' (or 'pnpm dev' / 'yarn dev') to start the development server"
echo "2. Open http://localhost:3000 in your browser"
echo "3. Check LocalStack dashboard: http://localhost:4566/_localstack/health"
echo ""
echo -e "${BLUE}Useful commands:${NC}"
echo "- npm run localstack:status  - Check LocalStack status"
echo "- npm run localstack:logs    - View LocalStack logs"
echo "- npm run localstack:stop    - Stop LocalStack"
echo "- npm run localstack:reset   - Reset LocalStack (clean slate)"
echo ""
