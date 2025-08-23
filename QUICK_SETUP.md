# 🚀 Quick Setup Guide

Get Cloud Tools running locally in under 5 minutes!

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (required)
- [Node.js 18+](https://nodejs.org/) (required)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) (recommended)

## One-Command Setup

```bash
npm run setup
```

That's it! This command will:
- ✅ Check all prerequisites
- ✅ Create `.env.local` configuration
- ✅ Install dependencies
- ✅ Start LocalStack with all AWS services
- ✅ Configure AWS CLI profile
- ✅ Create all required AWS resources (S3, DynamoDB, SQS)
- ✅ Verify everything is working

## Start Development

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

## Useful Commands

| Command | Description |
|---------|-------------|
| `npm run setup` | Complete setup (run once) |
| `npm run dev` | Start development server |
| `npm run verify` | Verify setup is working |
| `npm run test:integration` | Test full AWS/LocalStack integration |
| `npm run localstack:status` | Check LocalStack status |
| `npm run localstack:logs` | View LocalStack logs |
| `npm run localstack:health` | Check AWS services health |
| `npm run localstack:reset` | Reset LocalStack (clean slate) |

## Manual Setup (if needed)

If the automatic setup doesn't work:

1. **Start LocalStack:**
   ```bash
   docker compose up -d
   ```

2. **Configure AWS CLI:**
   ```bash
   aws configure --profile localstack
   # Use: test/test/us-east-1/json
   ```

3. **Create resources:**
   ```bash
   # S3 bucket
   aws --endpoint-url=http://localhost:4566 --profile localstack s3 mb s3://cloud-tools-local-bucket
   
   # DynamoDB table
   aws --endpoint-url=http://localhost:4566 --profile localstack dynamodb create-table \
     --table-name CloudToolsJobs \
     --attribute-definitions AttributeName=jobId,AttributeType=S \
     --key-schema AttributeName=jobId,KeyType=HASH \
     --billing-mode PAY_PER_REQUEST
   
   # SQS queue
   aws --endpoint-url=http://localhost:4566 --profile localstack sqs create-queue \
     --queue-name cloud-tools-jobs-queue
   ```

## Troubleshooting

### LocalStack won't start
- Make sure Docker Desktop is running
- Check if port 4566 is available: `lsof -i :4566`
- Reset LocalStack: `npm run localstack:reset`

### AWS CLI errors
- Verify AWS CLI is installed: `aws --version`
- Check profile: `aws configure list --profile localstack`
- Recreate profile: `aws configure --profile localstack`

### Resources not found
- Run verification: `npm run verify`
- Check LocalStack health: `npm run localstack:health`
- Reset and recreate: `npm run localstack:reset`

## What's Running?

- **Next.js App**: http://localhost:3000
- **Job Status Page**: http://localhost:3000/jobs
- **System Status Page**: http://localhost:3000/status
- **LocalStack Dashboard**: http://localhost:4566/_localstack/health
- **AWS Services**: All available at http://localhost:4566

## Need Help?

Check the main [README.md](./README.md) for detailed documentation or open an issue on GitHub.
