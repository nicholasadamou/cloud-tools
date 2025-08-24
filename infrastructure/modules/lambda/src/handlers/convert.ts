/**
 * Convert Lambda Handler
 *
 * Handles API Gateway requests for file conversion using your actual worker.ts processing logic
 */

import {
  APIGatewayProxyEvent,
  APIGatewayProxyResult,
  Context,
} from "aws-lambda";
import { createLambdaWorkerDependencies } from "../adapters/aws-lambda-adapter";
import {
  QueueWorker,
  SharpImageConverter,
  FFmpegVideoConverter,
  FFmpegAudioConverter,
  PDFCompressor,
  CalibreEBookConverter,
  ProcessingMessage,
  JobStatus,
} from "../../../../../lib/worker";

export const handler = async (
  event: APIGatewayProxyEvent,
  context: Context,
): Promise<APIGatewayProxyResult> => {
  console.log("Convert Lambda handler started", {
    requestId: context.awsRequestId,
    event: JSON.stringify(event),
  });

  // CORS headers for all responses
  const corsHeaders = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
      "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
    "Access-Control-Allow-Methods": "GET,OPTIONS,POST,PUT",
  };

  try {
    // Handle preflight CORS requests
    if (event.httpMethod === "OPTIONS") {
      return {
        statusCode: 200,
        headers: corsHeaders,
        body: "",
      };
    }

    // Parse request body
    if (!event.body) {
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({
          error: "Missing request body",
        }),
      };
    }

    const { jobId, inputFormat, outputFormat, fileName, s3Key, quality } =
      JSON.parse(event.body);

    // Validate required parameters
    if (!jobId || !inputFormat || !outputFormat || !fileName || !s3Key) {
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({
          error: "Missing required parameters",
          required: [
            "jobId",
            "inputFormat",
            "outputFormat",
            "fileName",
            "s3Key",
          ],
        }),
      };
    }

    // Create worker dependencies
    const dependencies = createLambdaWorkerDependencies();

    // Update job status to processing
    await dependencies.jobStatusUpdater.updateStatus(
      jobId,
      JobStatus.PROCESSING,
      0,
    );

    // Create processing message
    const processingMessage: ProcessingMessage = {
      jobId,
      operation: "convert",
      targetFormat: outputFormat,
      quality: quality || 80,
      timestamp: new Date().toISOString(),
      retryCount: 0,
    };

    // Create worker with processors
    const worker = new QueueWorker(
      dependencies.messageQueue,
      dependencies.fileStorage,
      dependencies.jobStatusUpdater,
      dependencies.logger,
    );

    // Add processors based on input/output formats
    worker.addProcessor(new SharpImageConverter());
    worker.addProcessor(new FFmpegVideoConverter());
    worker.addProcessor(new FFmpegAudioConverter());
    worker.addProcessor(new PDFCompressor());
    worker.addProcessor(new CalibreEBookConverter());

    // Process the job directly (Lambda execution model)
    try {
      // Get the file from S3
      const originalBuffer = await dependencies.fileStorage.getFile(s3Key);
      dependencies.logger.info(
        `Retrieved file from S3: ${s3Key}, size: ${originalBuffer.length} bytes`,
      );

      // Find appropriate processor
      const processor = worker["findProcessor"](processingMessage);
      if (!processor) {
        throw new Error(
          `No processor found for operation: convert, format: ${outputFormat}`,
        );
      }

      await dependencies.jobStatusUpdater.updateStatus(
        jobId,
        JobStatus.PROCESSING,
        25,
      );

      // Process the file
      const result = await processor.process(originalBuffer, processingMessage);
      await dependencies.jobStatusUpdater.updateStatus(
        jobId,
        JobStatus.PROCESSING,
        75,
      );

      // Generate output key and upload processed file
      const outputKey = `processed/${jobId}.${result.fileExtension}`;
      await dependencies.fileStorage.putFile(
        outputKey,
        result.buffer,
        result.contentType,
      );

      const downloadUrl =
        dependencies.fileStorage.generateDownloadUrl(outputKey);

      // Mark as completed
      await dependencies.jobStatusUpdater.updateStatus(
        jobId,
        JobStatus.COMPLETED,
        100,
        downloadUrl,
      );

      dependencies.logger.info(`Conversion completed for job ${jobId}`, {
        outputFormat,
        outputSize: result.buffer.length,
        downloadUrl,
      });

      return {
        statusCode: 200,
        headers: corsHeaders,
        body: JSON.stringify({
          message: "File conversion completed successfully",
          jobId,
          status: "completed",
          outputFormat,
          downloadUrl,
          outputSize: result.buffer.length,
        }),
      };
    } catch (processingError) {
      dependencies.logger.error(
        `Processing failed for job ${jobId}`,
        processingError,
      );

      await dependencies.jobStatusUpdater.updateStatus(
        jobId,
        JobStatus.FAILED,
        0,
      );

      throw processingError;
    }
  } catch (error) {
    console.error("Convert Lambda error:", error);

    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({
        error: "Internal server error",
        message: error instanceof Error ? error.message : "Unknown error",
        requestId: context.awsRequestId,
      }),
    };
  }
};
