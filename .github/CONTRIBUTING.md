# Contributing to Cloud Tools

Thank you for your interest in contributing to Cloud Tools! This guide will help you get set up for development.

## 🚀 Quick Start for Contributors

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (required)
- [Node.js 18+](https://nodejs.org/) (required)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) (recommended)

### One-Command Setup

```bash
git clone <repository-url>
cd cloud-tools
pnpm run setup
```

This will:

- ✅ Install all dependencies
- ✅ Start LocalStack with AWS services
- ✅ Create `.env.local` configuration
- ✅ Set up AWS CLI profile
- ✅ Create all required resources (S3, DynamoDB, SQS)
- ✅ Verify everything is working

### Start Development

```bash
pnpm run dev
```

Your app will be running at [http://localhost:3000](http://localhost:3000)

## 🛠️ Development Workflow

### Available Scripts

| Command                       | Description                             |
| ----------------------------- | --------------------------------------- |
| `pnpm run setup`              | Complete setup (run once after cloning) |
| `pnpm run dev`                | Start client development server         |
| `pnpm run build`              | Build client for production             |
| `pnpm run verify`             | Verify local setup is working           |
| **Monorepo Commands**         | **Workspace Management**                |
| `pnpm run type-check:all`     | Type check all workspaces               |
| `pnpm run lambda:type-check`  | Type check Lambda functions only        |
| `pnpm run lambda:build`       | Build Lambda functions                  |
| `pnpm run lambda:clean`       | Clean Lambda dist directory             |
| `pnpm run build:all`          | Build both client and Lambda            |
| **LocalStack Management**     | **Local AWS Services**                  |
| `pnpm run localstack:status`  | Check LocalStack container status       |
| `pnpm run localstack:logs`    | View LocalStack logs                    |
| `pnpm run localstack:health`  | Check AWS services health               |
| `pnpm run localstack:restart` | Restart LocalStack                      |
| `pnpm run localstack:reset`   | Reset LocalStack (clean slate)          |
| `pnpm run localstack:stop`    | Stop LocalStack                         |

### Monorepo Structure

```
cloud-tools/
├── client/                     # 🖥️ Next.js web application (@cloud-tools/client)
│   ├── app/                   # Next.js app directory
│   ├── components/            # React components
│   ├── lib/                   # Client-specific utilities
│   └── test/                  # Client tests
├── infrastructure/             # 🏗️ Terraform and AWS infrastructure
│   └── modules/lambda/src/    # 📦 Lambda functions (@cloud-tools/lambda)
│       ├── handlers/          # Lambda function handlers
│       ├── adapters/          # AWS service adapters
│       └── tsconfig.json      # Lambda TypeScript config
├── lib/                       # 📚 Shared libraries and utilities
│   ├── aws-config.ts         # AWS configuration
│   └── worker.ts             # File processing logic
├── docs/                      # 📖 Documentation
├── scripts/                   # 🔧 Development scripts
├── .localstack/               # LocalStack initialization scripts
├── docker-compose.yml         # LocalStack service definition
├── pnpm-workspace.yaml        # PNPM workspace configuration
├── .env.local.example         # Environment variables template
└── .env.local                # Your local environment (auto-created)
```

## 🔧 Working with AWS Services

### LocalStack Services Available

- **S3**: File storage at http://localhost:4566
- **DynamoDB**: NoSQL database for job tracking
- **SQS**: Message queue for async processing
- **CloudWatch**: Basic logging
- **Lambda**: Function execution (when needed)

### AWS CLI Commands

All AWS CLI commands should use the LocalStack profile:

```bash
# List S3 buckets
aws --profile localstack --endpoint-url=http://localhost:4566 s3 ls

# Query DynamoDB
aws --profile localstack --endpoint-url=http://localhost:4566 dynamodb scan --table-name CloudToolsJobs

# List SQS queues
aws --profile localstack --endpoint-url=http://localhost:4566 sqs list-queues
```

### Adding AWS SDK Code

1. Install required AWS SDK packages:

   ```bash
   pnpm install @aws-sdk/client-s3 @aws-sdk/client-dynamodb @aws-sdk/client-sqs @aws-sdk/lib-dynamodb
   ```

2. Use the example configuration:

   ```bash
   cp lib/aws-config.example.ts lib/aws-config.ts
   ```

3. Import and use in your code:
   ```typescript
   import { s3Client, uploadFileToS3 } from "@/lib/aws-config";
   ```

## 🏗️ Working with the Monorepo

### Workspace Commands

**Client workspace (`@cloud-tools/client`):**

```bash
# Work specifically with the client
pnpm --filter client dev         # Start client dev server
pnpm --filter client build       # Build client
pnpm --filter client test        # Run client tests
pnpm --filter client type-check  # Type check client
```

**Lambda workspace (`@cloud-tools/lambda`):**

```bash
# Work specifically with Lambda functions
pnpm --filter @cloud-tools/lambda build       # Build Lambda functions
pnpm --filter @cloud-tools/lambda type-check  # Type check Lambda
pnpm --filter @cloud-tools/lambda clean       # Clean Lambda dist
```

### Shared Dependencies

The `lib/` directory contains shared code used by both workspaces:

- **`lib/aws-config.ts`**: AWS service configuration
- **`lib/worker.ts`**: File processing logic

### Path Aliases

Both workspaces use path aliases for cleaner imports:

**Client paths:**

- `@/lib/*` → `./lib/*` (client-specific)
- `@/root-lib/*` → `../lib/*` (shared root lib)
- `@/*` → `./*` (client root)

**Lambda paths:**

- `@/lib/*` → `../../../../lib/*` (shared root lib)
- `@/handlers/*` → `./handlers/*` (Lambda handlers)
- `@/adapters/*` → `./adapters/*` (AWS adapters)

## 🐛 Troubleshooting

### LocalStack Issues

```bash
# Check if LocalStack is running
pnpm run localstack:status

# View logs for errors
pnpm run localstack:logs

# Reset everything (nuclear option)
pnpm run localstack:reset
```

### Environment Issues

```bash
# Verify setup
pnpm run verify

# Recreate .env.local
rm .env.local && cp .env.local.example .env.local
```

### AWS CLI Issues

```bash
# Recreate LocalStack profile
aws configure --profile localstack
# Use: test/test/us-east-1/json
```

## 📝 Making Changes

### Code Style

- Follow the existing code style
- Use TypeScript for type safety
- Use Tailwind CSS for styling
- Follow React/Next.js best practices

### Testing Changes

1. Verify setup: `pnpm run verify`
2. Test functionality manually
3. Check LocalStack logs: `pnpm run localstack:logs`
4. Reset if needed: `pnpm run localstack:reset`

### Before Submitting PR

- [ ] Code follows existing patterns
- [ ] LocalStack integration works
- [ ] No hardcoded AWS endpoints (use environment variables)
- [ ] Documentation updated if needed

## 📚 Learning Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [LocalStack Documentation](https://docs.localstack.cloud/)
- [AWS SDK v3 Documentation](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)

## 🆘 Getting Help

- Check the [QUICK_SETUP.md](../QUICK_SETUP.md) guide
- Review the main [README.md](../README.md)
- Open an issue on GitHub
- Check LocalStack health: `pnpm run localstack:health`

## 💡 Development Tips

1. **Use the verification script often**: `pnpm run verify`
2. **Monitor LocalStack logs**: `pnpm run localstack:logs` (in separate terminal)
3. **Reset when things get weird**: `pnpm run localstack:reset`
4. **Check service health**: `pnpm run localstack:health`
5. **Use AWS CLI with LocalStack**: Always include `--profile localstack --endpoint-url=http://localhost:4566`

Happy coding! 🚀
