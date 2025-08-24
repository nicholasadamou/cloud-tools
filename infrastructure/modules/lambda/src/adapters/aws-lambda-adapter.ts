/**
 * Lambda-specific adapter for AWS services
 *
 * This adapter creates Lambda-optimized implementations of your worker interfaces
 * using the same AWS configuration and services from your existing codebase.
 */

import {
  MessageQueue,
  FileStorage,
  JobStatusUpdater,
  Logger,
  ProcessingMessage,
  JobStatus,
} from "@/lib/worker";
import {
  S3Client,
  GetObjectCommand,
  PutObjectCommand,
} from "@aws-sdk/client-s3";
import {
  SQSClient,
  ReceiveMessageCommand,
  DeleteMessageCommand,
  Message,
} from "@aws-sdk/client-sqs";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, UpdateCommand } from "@aws-sdk/lib-dynamodb";

/**
 * Lambda-optimized S3 file storage implementation
 */
export class LambdaS3FileStorage implements FileStorage {
  private s3Client: S3Client;

  constructor(
    private bucketName: string,
    private endpointUrl?: string,
  ) {
    this.s3Client = new S3Client({
      region: process.env.AWS_REGION || "us-east-1",
      ...(endpointUrl && { endpoint: endpointUrl }),
    });
  }

  async getFile(key: string): Promise<Buffer> {
    console.log(`🔍 Getting file from S3: ${key}`);

    const command = new GetObjectCommand({
      Bucket: this.bucketName,
      Key: key,
    });

    const result = await this.s3Client.send(command);
    if (!result.Body) {
      throw new Error(`File not found: ${key}`);
    }

    return Buffer.from(await result.Body.transformToByteArray());
  }

  async putFile(
    key: string,
    buffer: Buffer,
    contentType: string,
  ): Promise<void> {
    console.log(`📁 Putting file to S3: ${key} (${contentType})`);

    const command = new PutObjectCommand({
      Bucket: this.bucketName,
      Key: key,
      Body: buffer,
      ContentType: contentType,
    });

    await this.s3Client.send(command);
  }

  generateDownloadUrl(key: string): string {
    return `https://${this.bucketName}.s3.amazonaws.com/${key}`;
  }
}

/**
 * Lambda-optimized SQS message queue implementation
 */
export class LambdaSqsMessageQueue implements MessageQueue {
  private sqsClient: SQSClient;

  constructor(private queueUrl: string) {
    this.sqsClient = new SQSClient({
      region: process.env.AWS_REGION || "us-east-1",
    });
  }

  async pollMessages(): Promise<Message[]> {
    const command = new ReceiveMessageCommand({
      QueueUrl: this.queueUrl,
      MaxNumberOfMessages: 1,
      WaitTimeSeconds: 20,
      MessageAttributeNames: ["All"],
    });

    const result = await this.sqsClient.send(command);
    return result.Messages || [];
  }

  async deleteMessage(receiptHandle: string): Promise<void> {
    const command = new DeleteMessageCommand({
      QueueUrl: this.queueUrl,
      ReceiptHandle: receiptHandle,
    });

    await this.sqsClient.send(command);
  }
}

/**
 * Lambda-optimized DynamoDB job status updater
 */
export class LambdaJobStatusUpdater implements JobStatusUpdater {
  private dynamodb: DynamoDBDocumentClient;

  constructor(private tableName: string) {
    const dynamoClient = new DynamoDBClient({
      region: process.env.AWS_REGION || "us-east-1",
    });
    this.dynamodb = DynamoDBDocumentClient.from(dynamoClient);
  }

  async updateStatus(
    jobId: string,
    status: JobStatus,
    progress?: number,
    downloadUrl?: string,
    compressionData?: {
      originalFileSize?: number;
      processedFileSize?: number;
      compressionSavings?: number;
    },
  ): Promise<void> {
    const updateData: Record<string, any> = {
      status,
      updatedAt: new Date().toISOString(),
      progress,
    };

    if (downloadUrl) {
      updateData.downloadUrl = downloadUrl;
    }

    if (compressionData) {
      updateData.originalFileSize = compressionData.originalFileSize;
      updateData.processedFileSize = compressionData.processedFileSize;
      updateData.compressionSavings = compressionData.compressionSavings;
    }

    const command = new UpdateCommand({
      TableName: this.tableName,
      Key: { jobId },
      UpdateExpression:
        "SET #status = :status, updatedAt = :updatedAt, progress = :progress" +
        (downloadUrl ? ", downloadUrl = :downloadUrl" : "") +
        (compressionData?.originalFileSize
          ? ", originalFileSize = :originalFileSize"
          : "") +
        (compressionData?.processedFileSize
          ? ", processedFileSize = :processedFileSize"
          : "") +
        (compressionData?.compressionSavings
          ? ", compressionSavings = :compressionSavings"
          : ""),
      ExpressionAttributeNames: {
        "#status": "status",
      },
      ExpressionAttributeValues: updateData.downloadUrl
        ? {
            ":status": status,
            ":updatedAt": updateData.updatedAt,
            ":progress": progress,
            ...(downloadUrl && { ":downloadUrl": downloadUrl }),
            ...(compressionData?.originalFileSize && {
              ":originalFileSize": compressionData.originalFileSize,
            }),
            ...(compressionData?.processedFileSize && {
              ":processedFileSize": compressionData.processedFileSize,
            }),
            ...(compressionData?.compressionSavings && {
              ":compressionSavings": compressionData.compressionSavings,
            }),
          }
        : {
            ":status": status,
            ":updatedAt": updateData.updatedAt,
            ":progress": progress,
          },
    });

    await this.dynamodb.send(command);
  }
}

/**
 * Lambda-optimized console logger
 */
export class LambdaLogger implements Logger {
  info(message: string, data?: unknown): void {
    console.log(
      JSON.stringify({
        timestamp: new Date().toISOString(),
        level: "INFO",
        message,
        ...(data ? { data } : {}),
      }),
    );
  }

  error(message: string, error?: unknown): void {
    console.error(
      JSON.stringify({
        timestamp: new Date().toISOString(),
        level: "ERROR",
        message,
        ...(error
          ? { error: error instanceof Error ? error.message : error }
          : {}),
      }),
    );
  }

  warn(message: string, data?: unknown): void {
    console.warn(
      JSON.stringify({
        timestamp: new Date().toISOString(),
        level: "WARN",
        message,
        ...(data ? { data } : {}),
      }),
    );
  }
}

/**
 * Factory function to create Lambda-optimized worker dependencies
 */
export function createLambdaWorkerDependencies() {
  const bucketName = process.env.S3_BUCKET_NAME!;
  const queueUrl = process.env.SQS_QUEUE_URL!;
  const tableName = process.env.DYNAMODB_TABLE_NAME!;

  if (!bucketName || !queueUrl || !tableName) {
    throw new Error(
      "Missing required environment variables: S3_BUCKET_NAME, SQS_QUEUE_URL, DYNAMODB_TABLE_NAME",
    );
  }

  return {
    fileStorage: new LambdaS3FileStorage(bucketName),
    messageQueue: new LambdaSqsMessageQueue(queueUrl),
    jobStatusUpdater: new LambdaJobStatusUpdater(tableName),
    logger: new LambdaLogger(),
  };
}
