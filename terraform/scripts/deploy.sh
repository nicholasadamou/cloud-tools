#!/bin/bash

# Cloud Tools Terraform Deployment Script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT=""
ACTION=""
AUTO_APPROVE=false
SKIP_PLAN=false

# Functions
print_usage() {
    echo "Usage: $0 -e <environment> -a <action> [options]"
    echo ""
    echo "Arguments:"
    echo "  -e, --environment    Environment (dev, staging, production)"
    echo "  -a, --action         Action (plan, apply, destroy, validate)"
    echo ""
    echo "Options:"
    echo "  -y, --auto-approve   Auto-approve apply/destroy (use with caution)"
    echo "  -s, --skip-plan      Skip plan step when applying"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -e dev -a plan"
    echo "  $0 -e production -a apply"
    echo "  $0 -e dev -a destroy -y"
}

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

validate_environment() {
    if [[ ! "$1" =~ ^(dev|staging|production)$ ]]; then
        error "Invalid environment: $1. Must be one of: dev, staging, production"
    fi
}

validate_action() {
    if [[ ! "$1" =~ ^(plan|apply|destroy|validate)$ ]]; then
        error "Invalid action: $1. Must be one of: plan, apply, destroy, validate"
    fi
}

check_prerequisites() {
    log "Checking prerequisites..."

    # Check if terraform is installed
    if ! command -v terraform &> /dev/null; then
        error "Terraform is not installed or not in PATH"
    fi

    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        error "AWS CLI is not installed or not in PATH"
    fi

    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        error "AWS credentials not configured or invalid"
    fi

    log "Prerequisites check passed"
}

setup_backend() {
    local env=$1
    log "Setting up Terraform backend for $env environment..."

    local backend_file="environments/$env/backend-$env.tfvars"
    if [[ ! -f "$backend_file" ]]; then
        error "Backend configuration file not found: $backend_file"
    fi

    # Initialize terraform with backend configuration
    cd "environments/$env"
    terraform init -backend-config="backend-$env.tfvars" -upgrade
    cd - > /dev/null
}

run_terraform_action() {
    local env=$1
    local action=$2

    cd "environments/$env"

    case $action in
        validate)
            log "Validating Terraform configuration for $env..."
            terraform validate
            ;;
        plan)
            log "Planning Terraform deployment for $env..."
            terraform plan -out="tfplan-$env"
            ;;
        apply)
            log "Applying Terraform configuration for $env..."
            if [[ "$SKIP_PLAN" == "false" ]]; then
                terraform plan -out="tfplan-$env"
            fi

            if [[ "$AUTO_APPROVE" == "true" ]]; then
                terraform apply -auto-approve "tfplan-$env"
            else
                terraform apply "tfplan-$env"
            fi
            ;;
        destroy)
            warn "This will DESTROY all resources in the $env environment!"
            if [[ "$AUTO_APPROVE" == "false" ]]; then
                read -r -p "Are you sure you want to continue? (yes/no): " confirm
                if [[ "$confirm" != "yes" ]]; then
                    log "Destroy cancelled"
                    exit 0
                fi
            fi

            log "Destroying Terraform resources for $env..."
            if [[ "$AUTO_APPROVE" == "true" ]]; then
                terraform destroy -auto-approve
            else
                terraform destroy
            fi
            ;;
    esac

    cd - > /dev/null
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -a|--action)
            ACTION="$2"
            shift 2
            ;;
        -y|--auto-approve)
            AUTO_APPROVE=true
            shift
            ;;
        -s|--skip-plan)
            SKIP_PLAN=true
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

# Validate required arguments
if [[ -z "$ENVIRONMENT" ]]; then
    error "Environment is required. Use -e or --environment"
fi

if [[ -z "$ACTION" ]]; then
    error "Action is required. Use -a or --action"
fi

# Validate arguments
validate_environment "$ENVIRONMENT"
validate_action "$ACTION"

# Main execution
log "Starting Terraform deployment script"
log "Environment: $ENVIRONMENT"
log "Action: $ACTION"

check_prerequisites
setup_backend "$ENVIRONMENT"
run_terraform_action "$ENVIRONMENT" "$ACTION"

log "Terraform $ACTION completed successfully for $ENVIRONMENT environment"
