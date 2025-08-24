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
| `pnpm run dev`                | Start development server                |
| `pnpm run build`              | Build for production                    |
| `pnpm run verify`             | Verify local setup is working           |
| `pnpm run localstack:status`  | Check LocalStack container status       |
| `pnpm run localstack:logs`    | View LocalStack logs                    |
| `pnpm run localstack:health`  | Check AWS services health               |
| `pnpm run localstack:restart` | Restart LocalStack                      |
| `pnpm run localstack:reset`   | Reset LocalStack (clean slate)          |
| `pnpm run localstack:stop`    | Stop LocalStack                         |

### Project Structure

```
cloud-tools/
├── app/                 # Next.js app directory
├── components/          # React components
├── lib/                 # Utilities and AWS configuration
├── scripts/             # Development scripts
├── .localstack/         # LocalStack initialization scripts
├── docker-compose.yml   # LocalStack service definition
├── .env.local.example   # Environment variables template
└── .env.local          # Your local environment (auto-created)
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
   import { s3Client, uploadFileToS3 } from '@/lib/aws-config';
   ```

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
