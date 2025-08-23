# File Processing Worker Setup

## Overview
The Cloud Tools application uses an SQS-based queue system for processing file conversions and compressions. This document explains how to set up and run the file processing worker that handles these jobs.

## Architecture
```
1. User uploads file → S3
2. Job queued → SQS
3. Worker polls SQS → Processes files → Updates job status
4. User downloads converted file
```

## Quick Start

### 1. Ensure LocalStack is Running
```bash
pnpm run localstack:status
# If not running:
pnpm run localstack:start
```

### 2. Start the Worker (Required for File Processing)
```bash
# In a separate terminal window:
pnpm run worker
```

### 3. Start the Development Server
```bash
# In another terminal window:
pnpm run dev
```

### 4. Test Image Conversion
1. Go to http://localhost:3000/tools/converters/image
2. Upload an image file (JPG, PNG, etc.)
3. Select a target format (the current format will be excluded from dropdown)
4. Click "Convert Image"
5. Watch the Conversion History - status should change from "processing" → "completed"
6. Download the converted file

## Worker Details

### What the Worker Does
- **Polls SQS Queue**: Checks for new conversion jobs every 5 seconds
- **Downloads Files**: Gets original files from S3
- **Processes Images**: Uses Sharp library for format conversion and compression
- **Uploads Results**: Saves processed files back to S3
- **Updates Status**: Updates job status and provides download URLs

### Supported Operations
- **Image Conversion**: JPG ↔ PNG ↔ WebP ↔ GIF
- **Image Compression**: Reduces file size while maintaining quality
- **Progress Tracking**: Real-time status updates
- **Error Handling**: Failed jobs are marked appropriately

### Worker Console Output
```bash
🚀 Starting Cloud Tools File Processing Worker...
📋 Worker initialized: { queueUrl: '...', bucketName: '...' }
🔄 Processing job: abc123...
✅ Job completed: abc123
```

## Troubleshooting

### Worker Won't Start
```bash
# Check if LocalStack is running
pnpm run localstack:health

# Verify AWS resources exist
pnpm run verify
```

### Jobs Stuck in Processing
- Make sure the worker is running (`pnpm run worker`)
- Check worker console for error messages
- Verify Sharp is properly installed (`pnpm list sharp`)

### Download Links Not Working
- LocalStack S3 URLs: `http://localhost:4566/bucket-name/processed/...`
- Make sure LocalStack is accessible on port 4566

## Development Notes

### Worker Architecture
- **Development**: Simple Node.js process polling SQS
- **Production**: Would use AWS Lambda triggers or ECS/Fargate containers

### File Storage Structure
```
S3 Bucket Structure:
uploads/          # Original files
  └── jobId       # Raw uploaded file
processed/        # Converted files
  └── jobId.ext   # Processed file with new extension
```

### Adding New File Types
1. Install appropriate processing library
2. Update worker.ts conversion logic
3. Add file type detection in aws-config.ts

## Commands Reference

| Command | Description |
|---------|-------------|
| `pnpm run worker` | Start the file processing worker |
| `pnpm run dev` | Start the web application |
| `pnpm run localstack:status` | Check LocalStack status |
| `pnpm run localstack:reset` | Reset LocalStack and recreate resources |
| `pnpm run verify` | Verify complete setup |

## Production Deployment
For production, replace the worker script with:
- **AWS Lambda**: Triggered by SQS messages
- **ECS/Fargate**: Containerized worker processes
- **EC2**: Long-running worker instances
- **Kubernetes**: Worker pods with appropriate scaling

The worker code can be adapted for any of these deployment methods.
