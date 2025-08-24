#!/bin/bash

# ACT Interactive Runner for cloud-tools project
# This script provides an easy-to-use menu for running GitHub Actions locally

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Function to print colored output
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${PURPLE}ℹ️  $1${NC}"
}

# Function to check if ACT is installed
check_act_installed() {
    if ! command -v act &> /dev/null; then
        print_error "ACT is not installed!"
        echo ""
        echo "Install ACT using:"
        echo "  macOS: brew install act"
        echo "  Linux: curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash"
        exit 1
    fi
    print_success "ACT is installed ($(act --version))"
}

# Function to check if Docker is running
check_docker_running() {
    if ! docker ps &> /dev/null; then
        print_error "Docker is not running!"
        echo "Please start Docker Desktop and try again."
        exit 1
    fi
    print_success "Docker is running"
}

# Function to show available workflows
show_workflows() {
    print_header "Available GitHub Actions Workflows"
    cd "$PROJECT_ROOT"

    echo "📋 Listing all workflows and jobs..."
    echo ""

    if command -v pnpm &> /dev/null; then
        pnpm act:list
    else
        act --list
    fi
}

# Function to run quick validation
run_quick_check() {
    print_header "Quick Validation (Type Check)"
    cd "$PROJECT_ROOT"

    if command -v pnpm &> /dev/null; then
        print_info "Running: pnpm act:quick"
        pnpm act:quick
    else
        print_info "Running: act -W .github/workflows/ci.yml -j type-check"
        act -W .github/workflows/ci.yml -j type-check
    fi

    print_success "Quick validation completed!"
}

# Function to run full CI
run_full_ci() {
    print_header "Full CI Pipeline"
    cd "$PROJECT_ROOT"

    print_warning "This will take several minutes to complete..."
    echo "Do you want to continue? (y/N)"
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        if command -v pnpm &> /dev/null; then
            print_info "Running: pnpm act:ci"
            pnpm act:ci
        else
            print_info "Running: act -W .github/workflows/ci.yml"
            act -W .github/workflows/ci.yml
        fi
        print_success "Full CI pipeline completed!"
    else
        print_info "CI pipeline cancelled"
    fi
}

# Function to run specific job
run_specific_job() {
    print_header "Run Specific Job"

    echo "Available CI jobs:"
    echo "1. lint-and-format - Linting and code formatting"
    echo "2. type-check - TypeScript type checking"
    echo "3. test - Unit tests with coverage"
    echo "4. build - Next.js build verification"
    echo "5. security - Security audit"
    echo "6. shellcheck - Shell script validation"
    echo ""
    echo "Enter job number (1-6): "
    read -r job_choice

    case $job_choice in
        1)
            job_name="lint-and-format"
            script_name="act:ci:lint"
            ;;
        2)
            job_name="type-check"
            script_name="act:ci:type-check"
            ;;
        3)
            job_name="test"
            script_name="act:ci:test"
            ;;
        4)
            job_name="build"
            script_name="act:ci:build"
            ;;
        5)
            job_name="security"
            script_name="act:ci:security"
            ;;
        6)
            job_name="shellcheck"
            script_name="act:ci:shellcheck"
            ;;
        *)
            print_error "Invalid choice"
            return 1
            ;;
    esac

    print_info "Running job: $job_name"
    cd "$PROJECT_ROOT"

    if command -v pnpm &> /dev/null; then
        pnpm "$script_name"
    else
        act -W .github/workflows/ci.yml -j "$job_name"
    fi

    print_success "Job '$job_name' completed!"
}

# Function to run with verbose output
run_verbose() {
    print_header "Verbose CI Execution"
    cd "$PROJECT_ROOT"

    print_warning "This will show detailed execution logs..."
    echo "Do you want to continue? (y/N)"
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        if command -v pnpm &> /dev/null; then
            pnpm act:verbose
        else
            act -W .github/workflows/ci.yml --verbose
        fi
        print_success "Verbose execution completed!"
    else
        print_info "Verbose execution cancelled"
    fi
}

# Function to run dry run
run_dry_run() {
    print_header "Dry Run (No Execution)"
    cd "$PROJECT_ROOT"

    print_info "This will show what would be executed without running it..."

    if command -v pnpm &> /dev/null; then
        pnpm act:dry
    else
        act -W .github/workflows/ci.yml --dryrun
    fi

    print_success "Dry run completed!"
}

# Function to run shellcheck validation
run_shellcheck() {
    print_header "Shell Script Validation"
    cd "$PROJECT_ROOT"

    echo "Choose shellcheck validation:"
    echo "1. Basic ShellCheck (quick)"
    echo "2. Detailed analysis"
    echo "3. Security scan"
    echo "4. Full shellcheck workflow"
    echo "5. Local shellcheck (fastest)"
    echo ""
    echo "Enter choice (1-5): "
    read -r choice

    case $choice in
        1)
            print_info "Running: pnpm act:shellcheck:basic"
            if command -v pnpm &> /dev/null; then
                pnpm act:shellcheck:basic
            else
                act -W .github/workflows/shellcheck.yml -j shellcheck
            fi
            ;;
        2)
            print_info "Running: pnpm act:shellcheck:detailed"
            if command -v pnpm &> /dev/null; then
                pnpm act:shellcheck:detailed
            else
                act -W .github/workflows/shellcheck.yml -j shellcheck-detailed
            fi
            ;;
        3)
            print_info "Running: pnpm act:shellcheck:security"
            if command -v pnpm &> /dev/null; then
                pnpm act:shellcheck:security
            else
                act -W .github/workflows/shellcheck.yml -j security-scan
            fi
            ;;
        4)
            print_info "Running: pnpm act:shellcheck (full workflow)"
            if command -v pnpm &> /dev/null; then
                pnpm act:shellcheck
            else
                act -W .github/workflows/shellcheck.yml
            fi
            ;;
        5)
            print_info "Running: pnpm shellcheck (local)"
            if command -v pnpm &> /dev/null; then
                pnpm shellcheck
            else
                echo "pnpm not available, running shellcheck directly..."
                if command -v shellcheck &> /dev/null; then
                    shellcheck scripts/*.sh
                else
                    print_error "shellcheck not installed locally"
                fi
            fi
            ;;
        *)
            print_error "Invalid choice"
            return 1
            ;;
    esac

    print_success "ShellCheck validation completed!"
}

# Function to show system info
show_system_info() {
    print_header "System Information"

    echo "🖥️  Operating System: $(uname -s)"
    echo "🏗️  Architecture: $(uname -m)"
    echo "🐳 Docker Version: $(docker --version 2>/dev/null || echo 'Not available')"
    echo "⚡ ACT Version: $(act --version 2>/dev/null || echo 'Not installed')"
    echo "📦 Node.js Version: $(node --version 2>/dev/null || echo 'Not available')"
    echo "🧶 pnpm Version: $(pnpm --version 2>/dev/null || echo 'Not available')"
    echo ""
    echo "📁 Project Root: $PROJECT_ROOT"
    echo "📋 Available Workflows:"
    for workflow in "$PROJECT_ROOT/.github/workflows/"*.{yml,yaml}; do
        if [[ -f "$workflow" ]]; then
            echo "   - $(basename "$workflow")"
        fi
    done
}

# Main menu
show_main_menu() {
    clear
    print_header "🚀 ACT Local Runner - Cloud Tools Project"

    echo ""
    echo "Select an option:"
    echo ""
    echo "🔍 Quick Actions:"
    echo "  1. List all workflows and jobs"
    echo "  2. Quick validation (type-check only)"
    echo "  3. Dry run (see what would execute)"
    echo ""
    echo "🧪 Testing:"
    echo "  4. Run specific CI job"
    echo "  5. Full CI pipeline"
    echo "  6. Run with verbose output"
    echo "  7. Run shell script validation"
    echo ""
    echo "📊 Information:"
    echo "  8. Show system information"
    echo "  9. Open ACT documentation"
    echo ""
    echo "  0. Exit"
    echo ""
    echo -n "Enter your choice (0-9): "
}

# Function to open documentation
open_documentation() {
    local doc_file="$PROJECT_ROOT/docs/ACT_USAGE.md"

    if [[ -f "$doc_file" ]]; then
        print_info "Opening ACT usage documentation..."

        if command -v code &> /dev/null; then
            code "$doc_file"
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            open "$doc_file"
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            xdg-open "$doc_file" 2>/dev/null || cat "$doc_file"
        else
            cat "$doc_file"
        fi
    else
        print_error "Documentation file not found at $doc_file"
    fi
}

# Main execution
main() {
    # Initial checks
    check_act_installed
    check_docker_running

    while true; do
        show_main_menu
        read -r choice

        echo ""

        case $choice in
            1)
                show_workflows
                ;;
            2)
                run_quick_check
                ;;
            3)
                run_dry_run
                ;;
            4)
                run_specific_job
                ;;
            5)
                run_full_ci
                ;;
            6)
                run_verbose
                ;;
            7)
                run_shellcheck
                ;;
            8)
                show_system_info
                ;;
            9)
                open_documentation
                ;;
            0)
                print_success "Thanks for using ACT Local Runner!"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please try again."
                ;;
        esac

        echo ""
        echo "Press Enter to continue..."
        read -r
    done
}

# Handle script interruption
trap 'print_warning "Script interrupted"; exit 1' INT TERM

# Run main function
main "$@"
