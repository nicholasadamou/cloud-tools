import { S3Client } from '@aws-sdk/client-s3';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { SQSClient } from '@aws-sdk/client-sqs';
import { DynamoDBDocumentClient } from '@aws-sdk/lib-dynamodb';

// Determine if we're running in development mode with LocalStack
const isLocal = process.env.NODE_ENV === 'development';
const endpoint = isLocal ? process.env.AWS_ENDPOINT_URL : undefined;

// Common AWS client configuration
const awsConfig = {
  region: process.env.AWS_REGION || 'us-east-1',
  endpoint,
  credentials: isLocal ? {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || 'test',
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || 'test',
  } : undefined,
};

// S3 Client for file storage - with LocalStack-specific configuration
export const s3Client = new S3Client({
  ...awsConfig,
  forcePathStyle: isLocal, // Required for LocalStack S3
  ...(isLocal && {
    // Additional LocalStack-specific S3 configuration
    useAccelerateEndpoint: false,
    useDualstackEndpoint: false,
  }),
});

// DynamoDB Client for database operations
export const dynamoClient = new DynamoDBClient(awsConfig);

// DynamoDB Document Client for easier operations
export const docClient = DynamoDBDocumentClient.from(dynamoClient);

// SQS Client for queue operations - with LocalStack-specific configuration
export const sqsClient = new SQSClient({
  ...awsConfig,
  ...(isLocal && {
    // Force SQS to use the configured endpoint
    useQueueUrlAsEndpoint: false,
  }),
});

// Configuration constants
export const AWS_RESOURCES = {
  S3_BUCKET: process.env.S3_BUCKET_NAME || 'cloud-tools-local-bucket',
  DYNAMODB_TABLE: process.env.DDB_TABLE_NAME || 'CloudToolsJobs',
  SQS_QUEUE: process.env.SQS_QUEUE_NAME || 'cloud-tools-jobs-queue',
  SQS_QUEUE_URL: isLocal 
    ? `http://localhost:4566/000000000000/${process.env.SQS_QUEUE_NAME || 'cloud-tools-jobs-queue'}`
    : undefined, // Will be retrieved dynamically in production
} as const;

// Job status enum
export enum JobStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  COMPLETED = 'completed',
  FAILED = 'failed'
}

// Job types enum
export enum JobType {
  IMAGE_CONVERSION = 'image_conversion',
  IMAGE_COMPRESSION = 'image_compression',
  VIDEO_CONVERSION = 'video_conversion',
  AUDIO_CONVERSION = 'audio_conversion',
  PDF_COMPRESSION = 'pdf_compression',
  EBOOK_CONVERSION = 'ebook_conversion'
}

// Helper function to get SQS queue URL
export async function getSQSQueueUrl(queueName: string = AWS_RESOURCES.SQS_QUEUE): Promise<string> {
  if (isLocal) {
    // For LocalStack, always use our manually constructed URL to avoid DNS issues
    return `http://localhost:4566/000000000000/${queueName}`;
  }
  
  // In production, get the queue URL dynamically
  const { GetQueueUrlCommand } = await import('@aws-sdk/client-sqs');
  const command = new GetQueueUrlCommand({ QueueName: queueName });
  const response = await sqsClient.send(command);
  
  if (!response.QueueUrl) {
    throw new Error(`Queue URL not found for queue: ${queueName}`);
  }
  
  return response.QueueUrl;
}

// Helper function to get S3 bucket name
export async function getS3BucketName(): Promise<string> {
  return AWS_RESOURCES.S3_BUCKET;
}

// Helper function to generate S3 key
export function generateS3Key(jobId: string, fileName: string, folder: string = 'uploads'): string {
  const timestamp = new Date().toISOString().split('T')[0];
  const sanitizedFileName = fileName.replace(/[^a-zA-Z0-9.-]/g, '_');
  return `${folder}/${timestamp}/${jobId}/${sanitizedFileName}`;
}

// Helper function to get file extension
export function getFileExtension(fileName: string): string {
  return fileName.split('.').pop()?.toLowerCase() || '';
}

// Helper function to determine job type from file extension
export function getJobTypeFromFile(fileName: string, operation: 'convert' | 'compress'): JobType {
  const extension = getFileExtension(fileName);
  
  if (operation === 'compress') {
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].includes(extension)) {
      return JobType.IMAGE_COMPRESSION;
    }
    if (extension === 'pdf') {
      return JobType.PDF_COMPRESSION;
    }
  }
  
  if (operation === 'convert') {
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'tiff', 'svg'].includes(extension)) {
      return JobType.IMAGE_CONVERSION;
    }
    if (['mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv', 'webm'].includes(extension)) {
      return JobType.VIDEO_CONVERSION;
    }
    if (['mp3', 'wav', 'flac', 'aac', 'ogg', 'm4a', 'wma'].includes(extension)) {
      return JobType.AUDIO_CONVERSION;
    }
    if (['epub', 'mobi', 'azw', 'pdf', 'txt', 'doc', 'docx'].includes(extension)) {
      return JobType.EBOOK_CONVERSION;
    }
  }
  
  return JobType.IMAGE_CONVERSION; // Default fallback
}
