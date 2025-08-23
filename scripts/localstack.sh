#!/bin/bash

# LocalStack Management Script
# Provides easy commands to manage LocalStack container

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

# Function to check if LocalStack is running
is_localstack_running() {
    docker ps --format 'table {{.Names}}' | grep -q "cloud-tools-localstack"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 {start|stop|restart|status|logs|reset|health}"
    echo ""
    echo "Commands:"
    echo "  start    - Start LocalStack container"
    echo "  stop     - Stop LocalStack container"
    echo "  restart  - Restart LocalStack container"
    echo "  status   - Show LocalStack container status"
    echo "  logs     - Show LocalStack logs"
    echo "  reset    - Stop, remove, and restart LocalStack (clean slate)"
    echo "  health   - Check LocalStack health and services"
}

case "$1" in
    start)
        print_status "Starting LocalStack..."
        if is_localstack_running; then
            print_warning "LocalStack is already running"
        else
            docker compose up -d
            print_success "LocalStack started successfully!"
            
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
        fi
        ;;
    stop)
        print_status "Stopping LocalStack..."
        if is_localstack_running; then
            docker compose down
            print_success "LocalStack stopped successfully!"
        else
            print_warning "LocalStack is not running"
        fi
        ;;
    restart)
        print_status "Restarting LocalStack..."
        docker compose restart
        print_success "LocalStack restarted successfully!"
        ;;
    status)
        print_status "Checking LocalStack status..."
        if is_localstack_running; then
            print_success "LocalStack is running"
            docker ps --filter name=cloud-tools-localstack --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        else
            print_warning "LocalStack is not running"
        fi
        ;;
    logs)
        print_status "Showing LocalStack logs..."
        if is_localstack_running; then
            docker compose logs -f localstack
        else
            print_error "LocalStack is not running"
            exit 1
        fi
        ;;
    reset)
        print_status "Resetting LocalStack (clean slate)..."
        print_warning "This will destroy all LocalStack data and restart fresh"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker compose down -v
            docker compose up -d
            
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
            
            # Run initialization script to recreate AWS resources
            if [ -f ".localstack/01-create-resources.sh" ]; then
                print_status "Recreating AWS resources..."
                cd .localstack && bash 01-create-resources.sh
                cd ..
                print_success "AWS resources recreated!"
            else
                print_warning "Initialization script not found, you may need to create AWS resources manually"
            fi
            
            print_success "LocalStack reset completed!"
        else
            print_status "Reset cancelled"
        fi
        ;;
    health)
        print_status "Checking LocalStack health..."
        if curl -s http://localhost:4566/_localstack/health >/dev/null 2>&1; then
            health_response=$(curl -s http://localhost:4566/_localstack/health)
            print_success "LocalStack is healthy!"
            echo ""
            echo "Service Status:"
            echo "$health_response" | jq -r '.services | to_entries[] | "  \(.key): \(.value)"' 2>/dev/null || echo "$health_response"
            echo ""
            echo "Version: $(echo "$health_response" | jq -r '.version' 2>/dev/null || echo 'Unknown')"
            echo "Edition: $(echo "$health_response" | jq -r '.edition' 2>/dev/null || echo 'Unknown')"
        else
            print_error "LocalStack is not accessible at http://localhost:4566"
            exit 1
        fi
        ;;
    *)
        show_usage
        exit 1
        ;;
esac
