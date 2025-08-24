/**
 * Compress Lambda Handler
 *
 * Handles API Gateway requests for file compression using your actual worker.ts processing logic
 */

import { APIGatewayProxyEvent, APIGatewayProxyResult, Context } from 'aws-lambda';
import { createLambdaWorkerDependencies } from '../adapters/aws-lambda-adapter';
import {
  QueueWorker,
  SharpImageConverter,
  FFmpegVideoConverter,
  FFmpegAudioConverter,
  PDFCompressor,
  ProcessingMessage,
  JobStatus,
} from '../../../../../lib/worker';

export const handler = async (
  event: APIGatewayProxyEvent,
  context: Context
): Promise<APIGatewayProxyResult> => {
  console.log('Compress Lambda handler started', {
    requestId: context.awsRequestId,
    event: JSON.stringify(event),
  });

  // CORS headers for all responses
  const corsHeaders = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers':
      'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
    'Access-Control-Allow-Methods': 'GET,OPTIONS,POST,PUT',
  };

  try {
    // Handle preflight CORS requests
    if (event.httpMethod === 'OPTIONS') {
      return {
        statusCode: 200,
        headers: corsHeaders,
        body: '',
      };
    }

    // Parse request body
    if (!event.body) {
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({
          error: 'Missing request body',
        }),
      };
    }

    const { jobId, format, fileName, s3Key, quality, compressionLevel } = JSON.parse(event.body);

    // Validate required parameters
    if (!jobId || !format || !fileName || !s3Key) {
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({
          error: 'Missing required parameters',
          required: ['jobId', 'format', 'fileName', 's3Key'],
        }),
      };
    }

    // Create worker dependencies
    const dependencies = createLambdaWorkerDependencies();

    // Update job status to processing
    await dependencies.jobStatusUpdater.updateStatus(jobId, JobStatus.PROCESSING, 0);

    // Create processing message
    const processingMessage: ProcessingMessage = {
      jobId,
      operation: 'compress',
      targetFormat: format,
      quality: quality || 80,
      timestamp: new Date().toISOString(),
      retryCount: 0,
    };

    // Create worker with processors
    const worker = new QueueWorker(
      dependencies.messageQueue,
      dependencies.fileStorage,
      dependencies.jobStatusUpdater,
      dependencies.logger
    );

    // Add processors based on format
    worker.addProcessor(new SharpImageConverter());
    worker.addProcessor(new FFmpegVideoConverter());
    worker.addProcessor(new FFmpegAudioConverter());
    worker.addProcessor(new PDFCompressor());

    // Process the job directly (Lambda execution model)
    try {
      // Get the file from S3
      const originalBuffer = await dependencies.fileStorage.getFile(s3Key);
      dependencies.logger.info(
        `Retrieved file from S3: ${s3Key}, size: ${originalBuffer.length} bytes`
      );

      // Find appropriate processor
      const processor = worker['findProcessor'](processingMessage);
      if (!processor) {
        throw new Error(`No processor found for operation: compress, format: ${format}`);
      }

      await dependencies.jobStatusUpdater.updateStatus(jobId, JobStatus.PROCESSING, 25);

      // Process the file
      const result = await processor.process(originalBuffer, processingMessage);
      await dependencies.jobStatusUpdater.updateStatus(jobId, JobStatus.PROCESSING, 75);

      // Calculate compression ratio
      const originalSize = originalBuffer.length;
      const compressedSize = result.buffer.length;
      const compressionRatio = (((originalSize - compressedSize) / originalSize) * 100).toFixed(2);

      // Generate output key and upload compressed file
      const outputKey = `compressed/${jobId}.${result.fileExtension}`;
      await dependencies.fileStorage.putFile(outputKey, result.buffer, result.contentType);

      const downloadUrl = dependencies.fileStorage.generateDownloadUrl(outputKey);

      // Mark as completed
      await dependencies.jobStatusUpdater.updateStatus(
        jobId,
        JobStatus.COMPLETED,
        100,
        downloadUrl
      );

      dependencies.logger.info(`Compression completed for job ${jobId}`, {
        format,
        originalSize,
        compressedSize,
        compressionRatio: `${compressionRatio}%`,
        downloadUrl,
      });

      return {
        statusCode: 200,
        headers: corsHeaders,
        body: JSON.stringify({
          message: 'File compression completed successfully',
          jobId,
          status: 'completed',
          format,
          downloadUrl,
          originalSize,
          compressedSize,
          compressionRatio: `${compressionRatio}%`,
        }),
      };
    } catch (processingError) {
      dependencies.logger.error(`Processing failed for job ${jobId}`, processingError);

      await dependencies.jobStatusUpdater.updateStatus(jobId, JobStatus.FAILED, 0);

      throw processingError;
    }
  } catch (error) {
    console.error('Compress Lambda error:', error);

    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({
        error: 'Internal server error',
        message: error instanceof Error ? error.message : 'Unknown error',
        requestId: context.awsRequestId,
      }),
    };
  }
};
