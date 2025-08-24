#!/bin/bash

# Terraform Linting Script for Local Development
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

info() {
    echo -e "${BLUE}[LINT]${NC} $1"
}

# Check if required tools are installed
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if terraform is installed
    if ! command -v terraform &> /dev/null; then
        error "Terraform is not installed or not in PATH"
        echo "Install from: https://www.terraform.io/downloads"
        exit 1
    fi
    
    # Check if tflint is installed (optional)
    if ! command -v tflint &> /dev/null; then
        warn "TFLint is not installed - only basic validation will be performed"
        echo "Install from: https://github.com/terraform-linters/tflint"
        TFLINT_AVAILABLE=false
    else
        TFLINT_AVAILABLE=true
    fi
    
    log "Prerequisites check completed"
}

# Format Terraform files
format_terraform() {
    log "Formatting Terraform files..."
    
    if terraform fmt -recursive .; then
        info "✅ Terraform files formatted successfully"
    else
        error "❌ Terraform formatting failed"
        return 1
    fi
}

# Check Terraform formatting
check_format() {
    log "Checking Terraform file formatting..."
    
    if terraform fmt -check -recursive .; then
        info "✅ All Terraform files are properly formatted"
    else
        error "❌ Some Terraform files need formatting"
        echo ""
        echo "Files that need formatting:"
        terraform fmt -check -recursive -diff .
        echo ""
        echo "Run 'terraform fmt -recursive .' to fix formatting"
        return 1
    fi
}

# Validate Terraform configurations
validate_terraform() {
    log "Validating Terraform configurations..."
    
    local validation_errors=0
    
    # Validate each environment
    for env_dir in environments/*/; do
        if [[ -d "$env_dir" ]]; then
            env_name=$(basename "$env_dir")
            info "📄 Validating environment: $env_name"
            
            cd "$env_dir"
            
            # Create temporary backend config for validation
            cat > backend-temp.tf << EOF
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
EOF
            
            # Initialize and validate
            if terraform init -backend=false > /dev/null 2>&1 && terraform validate > /dev/null 2>&1; then
                info "✅ $env_name - VALID"
            else
                error "❌ $env_name - INVALID"
                terraform validate
                validation_errors=$((validation_errors + 1))
            fi
            
            # Cleanup
            rm -f backend-temp.tf .terraform.lock.hcl
            rm -rf .terraform/
            
            cd - > /dev/null
        fi
    done
    
    if [ $validation_errors -eq 0 ]; then
        info "✅ All Terraform configurations are valid"
    else
        error "❌ Found validation errors in $validation_errors environment(s)"
        return 1
    fi
}

# Run TFLint if available
run_tflint() {
    if [[ "$TFLINT_AVAILABLE" != "true" ]]; then
        warn "Skipping TFLint - not installed"
        return 0
    fi
    
    log "Running TFLint analysis..."
    
    # Initialize TFLint
    if ! tflint --init > /dev/null 2>&1; then
        warn "TFLint initialization failed - skipping advanced linting"
        return 0
    fi
    
    local tflint_errors=0
    
    # Lint each module
    for module_dir in modules/*/; do
        if [[ -d "$module_dir" ]]; then
            module_name=$(basename "$module_dir")
            info "📄 Linting module: $module_name"
            
            if tflint --chdir="$module_dir" > /dev/null 2>&1; then
                info "✅ $module_name - PASSED"
            else
                error "❌ $module_name - FAILED"
                tflint --chdir="$module_dir"
                tflint_errors=$((tflint_errors + 1))
            fi
        fi
    done
    
    # Lint environments
    for env_dir in environments/*/; do
        if [[ -d "$env_dir" ]]; then
            env_name=$(basename "$env_dir")
            info "📄 Linting environment: $env_name"
            
            if tflint --chdir="$env_dir" > /dev/null 2>&1; then
                info "✅ $env_name - PASSED"
            else
                error "❌ $env_name - FAILED"
                tflint --chdir="$env_dir"
                tflint_errors=$((tflint_errors + 1))
            fi
        fi
    done
    
    if [ $tflint_errors -eq 0 ]; then
        info "✅ All modules and environments passed TFLint analysis"
    else
        error "❌ TFLint found issues in $tflint_errors component(s)"
        return 1
    fi
}

# Print usage information
print_usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -f, --format     Format Terraform files"
    echo "  -c, --check      Check formatting only (no changes)"
    echo "  -v, --validate   Validate Terraform configurations"
    echo "  -l, --lint       Run TFLint analysis"
    echo "  -a, --all        Run all checks (format check, validate, lint)"
    echo "  -h, --help       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --all                    # Run all linting checks"
    echo "  $0 --format                 # Format all Terraform files"
    echo "  $0 --check --validate       # Check formatting and validate"
}

# Main execution
main() {
    # Navigate to terraform directory
    cd "$(dirname "$0")/.."
    
    # Check prerequisites
    check_prerequisites
    
    local format_files=false
    local check_format_only=false
    local validate_configs=false
    local run_linting=false
    local run_all=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--format)
                format_files=true
                shift
                ;;
            -c|--check)
                check_format_only=true
                shift
                ;;
            -v|--validate)
                validate_configs=true
                shift
                ;;
            -l|--lint)
                run_linting=true
                shift
                ;;
            -a|--all)
                run_all=true
                shift
                ;;
            -h|--help)
                print_usage
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                print_usage
                exit 1
                ;;
        esac
    done
    
    # If no arguments, show usage
    if [[ "$format_files" == "false" && "$check_format_only" == "false" && "$validate_configs" == "false" && "$run_linting" == "false" && "$run_all" == "false" ]]; then
        print_usage
        exit 1
    fi
    
    local exit_code=0
    
    # Run requested operations
    if [[ "$run_all" == "true" ]]; then
        check_format_only=true
        validate_configs=true
        run_linting=true
    fi
    
    if [[ "$format_files" == "true" ]]; then
        format_terraform || exit_code=1
    fi
    
    if [[ "$check_format_only" == "true" ]]; then
        check_format || exit_code=1
    fi
    
    if [[ "$validate_configs" == "true" ]]; then
        validate_terraform || exit_code=1
    fi
    
    if [[ "$run_linting" == "true" ]]; then
        run_tflint || exit_code=1
    fi
    
    # Summary
    if [ $exit_code -eq 0 ]; then
        log "🎉 All Terraform linting checks passed!"
    else
        error "❌ Some linting checks failed - please review and fix the issues above"
    fi
    
    exit $exit_code
}

# Run main function with all arguments
main "$@"
