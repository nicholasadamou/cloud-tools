# Pre-commit Hooks

This project uses pre-commit hooks to automatically format and validate code before commits. This helps maintain code quality and consistency across the repository.

## Setup

The pre-commit hooks are automatically installed when you run `pnpm install` (via the `prepare` script). If you need to install them manually:

```bash
# Install pre-commit hooks
pnpm run pre-commit:install

# Or use pre-commit directly
pre-commit install
```

## What's Included

### General File Checks

- **Trailing whitespace**: Removes trailing whitespace from files
- **End of file fixer**: Ensures files end with a newline
- **Large file check**: Prevents committing files larger than 1MB
- **Case conflict check**: Prevents case-sensitive filename conflicts
- **Merge conflict check**: Prevents committing files with merge conflict markers
- **YAML validation**: Validates YAML file syntax
- **JSON validation**: Validates JSON file syntax

### Terraform Formatting

- **terraform_fmt**: Automatically formats all Terraform files (.tf, .tfvars) to canonical format

## Usage

### Automatic (Recommended)

Pre-commit hooks run automatically when you commit:

```bash
git add .
git commit -m "your commit message"
# Hooks run automatically and may modify files
# If files are modified, you need to add and commit again
```

### Manual Execution

Run hooks on all files manually:

```bash
# Using npm script
pnpm run pre-commit:run

# Or directly with pre-commit
pre-commit run --all-files
```

Run hooks on specific files:

```bash
pre-commit run --files terraform/main.tf
```

### Terraform-Specific Commands

If you only want to format Terraform files:

```bash
# Format Terraform files
pnpm run terraform:fmt

# Check Terraform formatting (without modifying)
pnpm run terraform:fmt:check

# Validate Terraform configuration
pnpm run terraform:validate
```

## Troubleshooting

### Hook Installation Issues

If you encounter issues with hook installation:

```bash
# Remove existing hooks and reinstall
pre-commit uninstall
pre-commit install
```

### Skip Hooks (Not Recommended)

In rare cases where you need to skip hooks:

```bash
git commit -m "your message" --no-verify
```

### Python Version Issues

If you get Python-related errors:

```bash
# Make sure you have Python 3.6+ installed
python3 --version

# If using pyenv
pyenv local 3.12.0
pre-commit install
```

## Configuration

The pre-commit configuration is stored in `.pre-commit-config.yaml`. You can modify this file to:

- Add new hooks
- Change hook versions
- Modify hook arguments
- Add exclusions

After modifying the configuration, update the hooks:

```bash
pre-commit autoupdate
```

## Benefits

1. **Consistent Formatting**: All Terraform files are automatically formatted using the standard Terraform formatter
2. **Early Error Detection**: Syntax errors in YAML/JSON files are caught before commit
3. **Cleaner History**: No more commits just to fix formatting issues
4. **Team Consistency**: All team members follow the same formatting standards
5. **Reduced CI/CD Failures**: Formatting checks pass locally before reaching CI/CD

## Integration with CI/CD

The same formatting checks that run locally also run in our GitHub Actions workflows. This ensures that:

1. Code that passes locally will also pass in CI/CD
2. All code in the repository follows consistent standards
3. Pull requests are automatically validated for formatting

If the pre-commit hooks are working correctly, you should rarely see formatting failures in CI/CD.
