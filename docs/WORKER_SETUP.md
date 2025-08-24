# File Processing Worker Setup

## Overview

The Cloud Tools application uses a comprehensive, SOLID-principle based file processing worker system for handling multimedia file conversions and compressions. The worker uses an SQS-based queue system and supports multiple file types with extensible processors.

## Architecture

```
1. User uploads file → S3 (uploads/)
2. Job queued → SQS with job metadata
3. Worker polls SQS → Retrieves file → Processes → Stores result → Updates status
4. Processed file stored → S3 (processed/)
5. User downloads converted/compressed file
```

## Supported File Types & Operations

### Images

- **Formats**: JPEG, PNG, WebP, GIF, TIFF, BMP
- **Operations**: Convert, Compress
- **Processor**: SharpImageConverter
- **Features**: Progressive JPEG, palette optimization, dimension scaling, format-specific optimizations

### Videos

- **Formats**: MP4, MOV, AVI, WebM, MKV, FLV, WMV
- **Operations**: Convert
- **Processor**: FFmpegVideoConverter
- **Features**: Codec selection, bitrate optimization, quality presets
- **Requires**: FFmpeg installation

### Audio

- **Formats**: MP3, WAV, OGG, FLAC, AAC, M4A, WMA
- **Operations**: Convert
- **Processor**: FFmpegAudioConverter
- **Features**: Bitrate optimization, codec-specific settings
- **Requires**: FFmpeg installation

### PDFs

- **Operations**: Compress
- **Processor**: PDFCompressor
- **Features**: Metadata removal, object stream optimization, structure optimization

### eBooks

- **Formats**: EPUB, MOBI, AZW3, PDF, TXT, DOCX, RTF
- **Operations**: Convert
- **Processor**: CalibreEBookConverter
- **Features**: Format-specific optimization, fallback handling for basic formats
- **Requires**: Calibre installation (with fallback for TXT conversion)

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

### 4. Test File Processing

#### Image Conversion/Compression

1. Go to http://localhost:3000/tools/converters/image
2. Upload an image file (JPG, PNG, WebP, GIF, TIFF, BMP)
3. Select a target format or compression quality
4. Click "Convert" or "Compress"
5. Watch the processing status change: "processing" → "completed"
6. Download the processed file

#### Other File Types

- **Video Conversion**: Upload video files (MP4, MOV, AVI, WebM, etc.)
- **Audio Conversion**: Upload audio files (MP3, WAV, FLAC, OGG, etc.)
- **PDF Compression**: Upload PDF files for size optimization
- **eBook Conversion**: Upload eBooks (EPUB, MOBI, etc.) for format conversion

## Worker Details

### What the Worker Does

- **Polls SQS Queue**: Continuously checks for new jobs (configurable interval, default 5 seconds)
- **Downloads Files**: Retrieves original files from S3 using job metadata
- **Multi-Format Processing**: Uses specialized processors for different file types:
  - **Sharp**: High-performance image processing with format-specific optimizations
  - **FFmpeg**: Professional video/audio conversion with quality presets
  - **PDF-lib**: PDF compression with metadata removal and structure optimization
  - **Calibre**: eBook conversion with fallback handling
- **Quality-Based Processing**: Applies different strategies based on quality settings
- **Uploads Results**: Stores processed files back to S3 with appropriate naming
- **Progress Tracking**: Updates job status at key processing stages (0% → 25% → 75% → 90% → 100%)
- **Compression Analytics**: Calculates and reports compression savings for compression operations

### Processing Capabilities

#### Image Processing (Sharp)

- **Conversion**: Format conversion with quality optimization
- **Compression**: Advanced compression with dimension scaling, progressive JPEG, palette optimization
- **Supported Formats**: JPEG, PNG, WebP, GIF, TIFF, BMP

#### Video Processing (FFmpeg)

- **Conversion**: Codec selection, bitrate optimization, quality presets
- **Format Support**: MP4 (H.264), WebM (VP9), MOV, AVI, MKV, FLV, WMV
- **Quality Settings**: Adjustable CRF values and bitrate ranges (1000k-8000k)

#### Audio Processing (FFmpeg)

- **Conversion**: Format-specific optimization with quality-based bitrates
- **Format Support**: MP3, WAV, OGG, FLAC, AAC, M4A, WMA
- **Codec Settings**: Optimized settings per format (VBR for MP3, compression levels for FLAC)

#### PDF Processing (PDF-lib)

- **Compression**: Metadata removal, object stream optimization
- **Structure Optimization**: Configurable processing based on quality settings

#### eBook Processing (Calibre + Fallback)

- **Full Conversion**: Uses Calibre for comprehensive format support
- **Fallback Support**: Basic text extraction when Calibre is unavailable
- **Format Support**: EPUB, MOBI, AZW3, PDF, TXT, DOCX, RTF

### Worker Console Output

```bash
🚀 Starting Cloud Tools File Processing Worker...
📋 This worker will poll the SQS queue for file conversion jobs
⚠️  This is a development worker - in production, use AWS Lambda or containers

🔧 Environment Configuration:
   NODE_ENV: development
   AWS_REGION: us-east-1
   AWS_ENDPOINT_URL: http://localhost:4566
   S3_BUCKET_NAME: cloud-tools-local-bucket
   DDB_TABLE_NAME: CloudToolsJobs
   SQS_QUEUE_NAME: cloud-tools-jobs-queue

ℹ️ Worker initialized {
  queueUrl: 'http://localhost:4566/000000000000/cloud-tools-jobs-queue',
  bucketName: 'cloud-tools-local-bucket',
  processors: ['SharpImageConverter', 'PDFCompressor', 'FFmpegVideoConverter', 'FFmpegAudioConverter', 'CalibreEBookConverter']
}
✅ Worker created successfully!
💡 Press Ctrl+C to stop the worker
📊 Check the console for job processing logs

ℹ️ Processing job: abc123
ℹ️ Compression achieved for job abc123: { originalSize: '2048 KB', processedSize: '1024 KB', savings: '50%' }
ℹ️ Job completed: abc123
```

## System Requirements

### Required

- **Node.js 18+**: Runtime environment
- **Docker Desktop**: For LocalStack AWS services
- **Sharp**: Image processing (auto-installed via pnpm)
- **PDF-lib**: PDF processing (auto-installed via pnpm)

### Optional (Enhanced Features)

- **FFmpeg**: Required for video/audio conversion

  ```bash
  # macOS
  brew install ffmpeg

  # Ubuntu/Debian
  sudo apt update && sudo apt install ffmpeg

  # Windows (using chocolatey)
  choco install ffmpeg
  ```

- **Calibre**: Required for eBook conversion

  ```bash
  # macOS
  brew install --cask calibre

  # Ubuntu/Debian
  sudo apt update && sudo apt install calibre

  # Windows: Download from https://calibre-ebook.com/download
  ```

### Environment Variables

The worker loads environment variables from (in order):

1. `.env.local` (development)
2. `.env.development.local`
3. `.env.development`
4. `.env`

## Troubleshooting

### Worker Won't Start

```bash
# Check if LocalStack is running
pnpm run localstack:health

# Verify AWS resources exist
pnpm run verify

# Check environment variables
cat .env.local
```

### Jobs Stuck in Processing

- Make sure the worker is running (`pnpm run worker`)
- Check worker console for error messages
- Verify required libraries:
  ```bash
  pnpm list sharp          # Image processing
  pnpm list fluent-ffmpeg-7 # Video/audio (if using)
  pnpm list pdf-lib        # PDF processing
  ```

### Processor-Specific Issues

#### FFmpeg Not Found (Video/Audio)

```bash
# Check if FFmpeg is installed
ffmpeg -version

# Install FFmpeg (see System Requirements above)
```

#### Calibre Not Found (eBooks)

```bash
# Check if Calibre is installed
ebook-convert --version

# Install Calibre (see System Requirements above)
# Note: Basic TXT conversion works without Calibre
```

#### Sharp Installation Issues (Images)

```bash
# Rebuild Sharp for your platform
pnpm rebuild sharp

# Or reinstall
pnpm uninstall sharp && pnpm install sharp
```

### Download Links Not Working

- LocalStack S3 URLs: `http://localhost:4566/bucket-name/processed/...`
- Make sure LocalStack is accessible on port 4566
- Check if processed file was actually created in S3:
  ```bash
  aws --profile localstack --endpoint-url=http://localhost:4566 s3 ls s3://cloud-tools-local-bucket/processed/
  ```

### Memory Issues (Large Files)

- Node.js has default memory limits
- For large file processing, increase memory:
  ```bash
  NODE_OPTIONS="--max-old-space-size=4096" pnpm run worker
  ```

### Performance Tuning

- **Poll Interval**: Adjust `pollIntervalMs` in worker constructor (default: 5000ms)
- **Concurrent Processing**: Current implementation processes jobs sequentially
- **Quality Settings**: Lower quality = faster processing + smaller files

## Development Notes

### Worker Architecture (SOLID Principles)

The worker is built following SOLID principles for maintainability and extensibility:

- **Single Responsibility**: Each class handles one concern (S3FileStorage, SharpImageConverter, etc.)
- **Open/Closed**: New processors can be added without modifying existing code
- **Liskov Substitution**: All processors implement the same FileProcessor interface
- **Interface Segregation**: Interfaces are focused on specific capabilities
- **Dependency Inversion**: Main worker depends on abstractions, not concrete implementations

**Deployment Options**:

- **Development**: Simple Node.js process polling SQS
- **Production**: AWS Lambda triggers, ECS/Fargate containers, or Kubernetes pods

### File Storage Structure

```
S3 Bucket Structure:
uploads/                    # Original files
  └── jobId                 # Raw uploaded file
processed/                  # Converted/compressed files
  ├── jobId.ext           # Converted file with new extension
  └── jobId_compressed.ext # Compressed file with original extension
```

### Adding New File Types

To add support for new file types, create a new processor:

1. **Create Processor Class**:

   ```typescript
   export class MyCustomProcessor implements FileProcessor {
     canProcess(operation: string, format?: string): boolean {
       // Define supported operations and formats
     }

     async process(buffer: Buffer, message: ProcessingMessage): Promise<ProcessingResult> {
       // Implement processing logic
     }
   }
   ```

2. **Register Processor**:

   ```typescript
   // In createFileProcessingWorker() function
   worker.addProcessor(new MyCustomProcessor());
   ```

3. **Install Dependencies**:

   ```bash
   pnpm install my-processing-library
   ```

4. **Update Type Detection** (if needed):
   Add MIME type mappings in `aws-config.ts`

### Key Components

#### Interfaces (Dependency Inversion)

- `FileProcessor`: Strategy pattern for different file types
- `FileStorage`: Abstraction for S3/storage operations
- `MessageQueue`: Abstraction for SQS/queue operations
- `JobStatusUpdater`: Abstraction for status updates
- `Logger`: Abstraction for logging operations

#### Concrete Implementations

- `SharpImageConverter`: High-performance image processing
- `FFmpegVideoConverter`: Professional video conversion
- `FFmpegAudioConverter`: Professional audio conversion
- `PDFCompressor`: PDF optimization and compression
- `CalibreEBookConverter`: eBook format conversion
- `S3FileStorage`: AWS S3 file operations
- `SqsMessageQueue`: AWS SQS queue operations
- `ApiJobStatusUpdater`: REST API status updates
- `ConsoleLogger`: Console-based logging

## Commands Reference

| Command                      | Description                             |
| ---------------------------- | --------------------------------------- |
| `pnpm run worker`            | Start the file processing worker        |
| `pnpm run dev`               | Start the web application               |
| `pnpm run localstack:status` | Check LocalStack status                 |
| `pnpm run localstack:reset`  | Reset LocalStack and recreate resources |
| `pnpm run verify`            | Verify complete setup                   |

## Production Deployment

For production, replace the worker script with:

- **AWS Lambda**: Triggered by SQS messages
- **ECS/Fargate**: Containerized worker processes
- **EC2**: Long-running worker instances
- **Kubernetes**: Worker pods with appropriate scaling

The worker code can be adapted for any of these deployment methods.
