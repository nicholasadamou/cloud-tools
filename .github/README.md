# GitHub Actions Workflows

This directory contains GitHub Actions workflows for automated CI/CD processes.

## Workflows

### 🧪 Test Workflows

#### [`test.yml`](.github/workflows/test.yml)
**Simple Unit Tests**
- Triggers: Push/PR to `main` and `develop` branches
- Node versions: 18.x, 20.x
- Features:
  - Runs linting and type checking
  - Executes unit tests
  - Generates coverage reports
  - Uploads to Codecov
  - Comments PR with coverage info

#### [`ci.yml`](.github/workflows/ci.yml)  
**Comprehensive CI Pipeline**
- Triggers: Push/PR to `main` and `develop` branches
- Jobs:
  - **Lint & Format**: ESLint and Prettier checks
  - **Type Check**: TypeScript compilation
  - **Test Matrix**: Tests across Node 18.x, 20.x, 22.x
  - **Build Check**: Verifies Next.js build succeeds
  - **Security Audit**: npm audit for vulnerabilities
  - **Summary**: Aggregates results

#### [`coverage.yml`](.github/workflows/coverage.yml)
**Test Coverage Analysis**
- Triggers: Push/PR to `main` branch
- Features:
  - Detailed coverage reporting
  - Coverage badge generation
  - Codecov and Coveralls integration
  - PR coverage comparison
  - Coverage threshold verification

#### [`test-environments.yml`](.github/workflows/test-environments.yml)
**Multi-Environment Testing**
- Triggers: Push/PR, daily schedule (2 AM UTC)
- Features:
  - **Test Matrix**: Cross-platform (Ubuntu, Windows, macOS)
  - **LocalStack Integration**: Tests with AWS services
  - **Docker Testing**: Tests in containerized environment  
  - **Performance Tests**: Monitors test execution time
  - **Notifications**: Alerts on failures

## Setup Instructions

### 1. Repository Settings

Add these to your repository secrets (Settings → Secrets and variables → Actions):

```bash
# Optional: For enhanced Codecov features
CODECOV_TOKEN=your_codecov_token

# Optional: For Coveralls integration  
COVERALLS_REPO_TOKEN=your_coveralls_token
```

### 2. Branch Protection Rules

Recommended branch protection for `main`:

- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date before merging
- ✅ Required status checks:
  - `Continuous Integration / Lint and Format Check`
  - `Continuous Integration / TypeScript Type Check` 
  - `Continuous Integration / Unit Tests (20.x)`
  - `Continuous Integration / Build Check`

### 3. Badge Integration

Add these badges to your main README.md:

```markdown
[![Tests](https://github.com/nicholasadamou/cloud-tools/workflows/Unit%20Tests/badge.svg)](https://github.com/nicholasadamou/cloud-tools/actions/workflows/test.yml)
[![CI](https://github.com/nicholasadamou/cloud-tools/workflows/Continuous%20Integration/badge.svg)](https://github.com/nicholasadamou/cloud-tools/actions/workflows/ci.yml)  
[![codecov](https://codecov.io/gh/nicholasadamou/cloud-tools/branch/main/graph/badge.svg)](https://codecov.io/gh/nicholasadamou/cloud-tools)
[![Coverage Status](https://coveralls.io/repos/github/nicholasadamou/cloud-tools/badge.svg?branch=main)](https://coveralls.io/github/nicholasadamou/cloud-tools?branch=main)
```

## Workflow Features

### 🔄 Automatic Triggers
- **Push events**: `main`, `develop` branches
- **Pull requests**: To `main`, `develop` branches  
- **Scheduled**: Daily integration tests (2 AM UTC)

### 📊 Coverage Reporting
- **Codecov**: Detailed coverage analysis
- **Coveralls**: Alternative coverage tracking
- **PR Comments**: Coverage changes in PR discussions
- **Badges**: Visual coverage status

### 🔧 Quality Checks
- **ESLint**: Code quality and style enforcement
- **Prettier**: Code formatting consistency
- **TypeScript**: Type safety verification
- **npm audit**: Security vulnerability scanning

### 🚀 Performance Monitoring  
- **Test timing**: Monitors test execution performance
- **Build verification**: Ensures production builds work
- **Multi-environment**: Tests across OS and Node versions

### 🐳 Container Testing
- **Docker**: Tests in isolated container environment
- **LocalStack**: AWS service integration testing
- **Cross-platform**: Ubuntu, Windows, macOS compatibility

## Troubleshooting

### Common Issues

1. **Test timeouts**: Adjust timeout in `vitest.config.ts` if needed
2. **Coverage thresholds**: Modify `codecov.yml` for your requirements  
3. **LocalStack connectivity**: Ensure health checks pass before tests
4. **Windows path issues**: Use forward slashes in scripts

### Debugging Failed Workflows

1. Check the Actions tab in your repository
2. Review logs for specific job failures
3. Local reproduction:
   ```bash
   npm run lint        # Check linting
   npm run type-check  # Check TypeScript
   npm test           # Run unit tests
   npm run build      # Verify build
   ```

## Best Practices

- **Small PRs**: Easier to review and test
- **Descriptive commits**: Clear change descriptions
- **Test coverage**: Maintain good coverage for business logic
- **Security updates**: Monitor and address audit findings
- **Performance**: Keep test execution time reasonable

---

For questions or issues with the CI/CD pipeline, please open an issue in the repository.
