# ACT - Local GitHub Actions Execution Guide

This comprehensive guide shows you how to run GitHub Actions workflows locally using [ACT](https://github.com/nektos/act) with the provided npm scripts and interactive tools.

## Table of Contents

- [Installation & Setup](#installation--setup)
- [Quick Start & Scripts](#quick-start--scripts)
- [Configuration](#configuration)
- [Usage Examples](#usage-examples)
- [Interactive Menu](#interactive-menu)
- [Troubleshooting](#troubleshooting)
- [Development Integration](#development-integration)
- [Advanced Features](#advanced-features)
- [Command Reference](#command-reference)

## Installation & Setup

### Prerequisites

- [Docker](https://www.docker.com/get-started) (Docker Desktop or equivalent)
- [Homebrew](https://brew.sh/) (on macOS)

### Install ACT

1. **Install ACT**:

   ```bash
   # macOS
   brew install act

   # Or using curl
   curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
   ```

2. **Docker**: Make sure Docker Desktop is running

3. **Required containers** will be downloaded automatically on first run

## Available Scripts

### Quick Commands

| Script             | Description                                |
| ------------------ | ------------------------------------------ |
| `pnpm act:list`    | List all available workflows and jobs      |
| `pnpm act:quick`   | Fast type-check only (quickest validation) |
| `pnpm act:dry`     | Dry run of CI workflow (no execution)      |
| `pnpm act:verbose` | Run CI with verbose output for debugging   |

### CI Workflow (`ci.yml`)

| Script                   | Job               | Description                        |
| ------------------------ | ----------------- | ---------------------------------- |
| `pnpm act:ci`            | All jobs          | Run complete CI pipeline           |
| `pnpm act:ci:lint`       | `lint-and-format` | Linting and code formatting checks |
| `pnpm act:ci:type-check` | `type-check`      | TypeScript type checking           |
| `pnpm act:ci:test`       | `test`            | Unit tests with coverage           |
| `pnpm act:ci:build`      | `build`           | Next.js build verification         |
| `pnpm act:ci:security`   | `security`        | Security audit                     |
| `pnpm act:ci:summary`    | `summary`         | CI results summary                 |

### Test Workflow (`test.yml`)

| Script          | Description             |
| --------------- | ----------------------- |
| `pnpm act:test` | Run unit tests workflow |

### Coverage Workflow (`coverage.yml`)

| Script                      | Job                   | Description                 |
| --------------------------- | --------------------- | --------------------------- |
| `pnpm act:coverage`         | All jobs              | Complete coverage analysis  |
| `pnpm act:coverage:report`  | `coverage`            | Generate coverage report    |
| `pnpm act:coverage:compare` | `coverage-comparison` | Compare PR vs base coverage |

### Test Environments (`test-environments.yml`)

| Script                     | Job                    | Description                       |
| -------------------------- | ---------------------- | --------------------------------- |
| `pnpm act:envs`            | All jobs               | Run all environment tests         |
| `pnpm act:envs:matrix`     | `test-matrix`          | Cross-platform matrix testing     |
| `pnpm act:envs:localstack` | `test-with-localstack` | Integration tests with LocalStack |
| `pnpm act:envs:docker`     | `test-docker`          | Tests in Docker container         |
| `pnpm act:envs:perf`       | `performance-tests`    | Performance benchmarks            |

### Combined Scripts

| Script           | Description                          |
| ---------------- | ------------------------------------ |
| `pnpm act:all`   | Run CI, Test, and Coverage workflows |
| `pnpm act:full`  | Run full CI test job (comprehensive) |
| `pnpm act:local` | Run tests with local optimizations   |

## Usage Examples

### 1. Quick Development Check

```bash
# Fast type-check - good for quick validation
pnpm act:quick

# See what would run without executing
pnpm act:dry
```

### 2. Pre-commit Validation

```bash
# Run linting and formatting checks
pnpm act:ci:lint

# Run type checking
pnpm act:ci:type-check

# Run both
pnpm act:ci:lint && pnpm act:ci:type-check
```

### 3. Full Testing Suite

```bash
# Run complete CI pipeline
pnpm act:ci

# Or run individual components
pnpm act:ci:test
pnpm act:coverage:report
```

### 4. Debugging Workflow Issues

```bash
# Enable verbose output
pnpm act:verbose

# List all available jobs
pnpm act:list

# Run specific job only
pnpm act:ci:test
```

### 5. Integration Testing

```bash
# Test with LocalStack (requires Docker)
pnpm act:envs:localstack

# Test in Docker environment
pnpm act:envs:docker
```

## Configuration

### Environment Variables

The workflows use these environment variables (set in `.actrc`):

- `NODE_ENV=test`
- `CI=true`
- `GITHUB_ACTIONS=true`

### ACT Configuration (`.actrc`)

- Uses `linux/amd64` architecture for M-series Mac compatibility
- Uses `catthehacker/ubuntu:act-latest` Docker image
- Sets default environment variables

## Troubleshooting

### Common Issues

1. **Architecture Mismatch (M-series Macs)**

   ```bash
   # Already configured in .actrc, but you can override:
   act --container-architecture linux/amd64
   ```

2. **Docker Memory Issues**

   ```bash
   # Increase Docker memory in Docker Desktop settings
   # Or add to .actrc:
   echo "--memory 4g" >> .actrc
   ```

3. **Verbose Debugging**

   ```bash
   pnpm act:verbose
   # Or add --verbose to any command
   pnpm run act:ci:test -- --verbose
   ```

4. **Container Not Found**

   ```bash
   # Pull required image manually
   docker pull catthehacker/ubuntu:act-latest
   ```

5. **LocalStack Issues**

   ```bash
   # Make sure Docker is running
   docker ps

   # Start LocalStack manually if needed
   pnpm localstack:start
   ```

### Performance Tips

1. **Reuse Containers**: Add `--reuse` to `.actrc` for faster subsequent runs
2. **Selective Jobs**: Run only the jobs you need instead of full workflows
3. **Skip Matrix**: Most workflows have matrix strategies; single jobs are faster
4. **Local Dependencies**: Use `pnpm act:local` for optimized local execution

## Matrix Testing Notes

Some workflows use matrix strategies that might be resource-intensive:

- `test-environments.yml` tests multiple OS/Node combinations
- Consider running specific jobs instead of the full matrix locally
- CI servers handle matrices better than local machines

## Integration with Development Workflow

### Pre-commit Hook

Add to `.husky/pre-commit`:

```bash
pnpm act:quick
```

### Pre-push Hook

Add to `.husky/pre-push`:

```bash
pnpm act:ci:test
```

### Development Loop

1. Make changes
2. `pnpm act:quick` - Fast validation
3. `pnpm act:ci:test` - Full test suite
4. `pnpm act:ci` - Complete CI check
5. Push with confidence!

## Interactive Menu

### Use the Interactive Script

For an easy-to-use menu interface, run:

```bash
pnpm act:menu
# or directly
./scripts/act-runner.sh
```

This provides an interactive menu with options for:

- Quick actions (list, validate, dry run)
- Testing (specific jobs, full CI, verbose output)
- Information (system info, documentation)

## Advanced Features

### Custom Environment Variables

```bash
# Set specific environment
act --env NODE_ENV=test --env CI=true

# Use environment file
act --env-file .env.test
```

### Secrets Management

```bash
# Pass secrets
act --secret GITHUB_TOKEN=your_token

# Use secrets file (add to .gitignore)
act --secret-file .secrets
```

### Event Simulation

```bash
# Simulate push event
act push

# Simulate pull request
act pull_request

# Simulate specific event with payload
act push --eventpath event.json
```

### Docker Configuration

```bash
# Use specific image
act -P ubuntu-latest=catthehacker/ubuntu:act-latest

# Bind Docker socket for Docker-in-Docker
act --bind

# Set resource limits
act --memory 4g --cpus 2
```

## Command Reference

### Essential Commands

```bash
act -l                           # List all workflows and jobs
act                              # Run all workflows (uses .actrc config)
act -W .github/workflows/ci.yml  # Run specific workflow
act -j lint-and-format          # Run specific job
act push                         # Simulate push event
act pull_request                 # Simulate pull request event
```

### Debug & Troubleshoot

```bash
act --verbose                    # Verbose output
act --dryrun                     # See what would run without executing
act -j test --env NODE_ENV=test  # Run with specific environment
act --list                       # List workflows and jobs
act --help                       # Show help
```

### Project-Specific Notes

- **Container Architecture**: Uses `linux/amd64` (configured in `.actrc`)
- **Package Manager**: Uses `pnpm` (workflows updated)
- **ESLint Version**: Uses ESLint 8.x for compatibility
- **Configuration File**: `.actrc` sets project defaults

### First Run Setup

1. Ensure Docker is running: `docker ps`
2. Verify ACT installation: `act --version`
3. List available workflows: `pnpm act:list`
4. Run a quick check: `pnpm act:quick`
5. Run full CI if needed: `pnpm act:ci`

### VS Code Integration

Add to `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "ACT: Quick Check",
      "type": "shell",
      "command": "pnpm",
      "args": ["act:quick"],
      "group": "test",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "panel": "new"
      }
    },
    {
      "label": "ACT: Run Tests",
      "type": "shell",
      "command": "pnpm",
      "args": ["act:ci:test"],
      "group": "test"
    }
  ]
}
```

### Workflow-Specific Information

#### CI Workflow (`ci.yml`)

The CI workflow includes these jobs:

- `lint-and-format`: ESLint and Prettier checks
- `type-check`: TypeScript type checking
- `security`: Security audit
- `test`: Unit tests with coverage (depends on lint/type-check)
- `build`: Next.js build verification (depends on lint/type-check)
- `summary`: Results summary (depends on all jobs)

#### Test Workflow (`test.yml`)

Runs tests across multiple Node.js versions (18.x, 20.x) with:

- Linting
- Type checking
- Unit tests
- Coverage reporting

#### Coverage Workflow (`coverage.yml`)

Generates and uploads coverage reports to Codecov with:

- Coverage report generation
- Coverage comparison for PRs
- Badge generation

### Quick Development Cycle Example

```bash
# 1. Make code changes

# 2. Run quick validation
pnpm act:quick

# 3. If passed, run linting
pnpm act:ci:lint

# 4. Run tests if linting passes
pnpm act:ci:test

# 5. Run full CI if all looks good
pnpm act:ci

# 6. Push with confidence!
```

### Cleanup Commands

```bash
# Remove ACT containers
docker container prune -f

# Remove ACT images (if needed)
docker image prune -f

# Remove specific ACT image
docker rmi catthehacker/ubuntu:act-latest
```

## Additional Resources

- [ACT Documentation](https://github.com/nektos/act)
- [ACT Runner Images](https://github.com/catthehacker/docker_images)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [LocalStack Documentation](https://docs.localstack.cloud/)
- [Project Scripts Reference](../package.json) - See all available `act:*` scripts
