/**
 * Process Lambda Handler
 *
 * Handles SQS queue messages for file processing using your actual worker.ts processing logic
 */

import { SQSEvent, SQSRecord, Context } from "aws-lambda";
import { createLambdaWorkerDependencies } from "@/adapters/aws-lambda-adapter";
import {
  QueueWorker,
  SharpImageConverter,
  FFmpegVideoConverter,
  FFmpegAudioConverter,
  PDFCompressor,
  CalibreEBookConverter,
  ProcessingMessage,
  JobStatus,
} from "@/lib/worker";

export const handler = async (
  event: SQSEvent,
  context: Context,
): Promise<void> => {
  console.log("Process Lambda handler started", {
    requestId: context.awsRequestId,
    recordCount: event.Records.length,
  });

  // Create worker dependencies
  const dependencies = createLambdaWorkerDependencies();

  // Create worker with all processors
  const worker = new QueueWorker(
    dependencies.messageQueue,
    dependencies.fileStorage,
    dependencies.jobStatusUpdater,
    dependencies.logger,
  );

  // Add all available processors
  worker.addProcessor(new SharpImageConverter());
  worker.addProcessor(new FFmpegVideoConverter());
  worker.addProcessor(new FFmpegAudioConverter());
  worker.addProcessor(new PDFCompressor());
  worker.addProcessor(new CalibreEBookConverter());

  // Process each SQS record
  const promises = event.Records.map(async (record: SQSRecord) => {
    try {
      dependencies.logger.info(`Processing SQS message ${record.messageId}`, {
        messageId: record.messageId,
        receiptHandle: record.receiptHandle,
      });

      // Parse the message body
      let processingMessage: ProcessingMessage;
      try {
        processingMessage = JSON.parse(record.body);
      } catch (parseError) {
        dependencies.logger.error("Failed to parse SQS message body", {
          messageId: record.messageId,
          body: record.body,
          error: parseError,
        });
        throw new Error(`Invalid message format: ${parseError}`);
      }

      // Validate required fields
      if (!processingMessage.jobId || !processingMessage.operation) {
        throw new Error("Missing required fields in processing message");
      }

      dependencies.logger.info(`Processing job ${processingMessage.jobId}`, {
        operation: processingMessage.operation,
        targetFormat: processingMessage.targetFormat,
      });

      // Update job status to processing
      await dependencies.jobStatusUpdater.updateStatus(
        processingMessage.jobId,
        JobStatus.PROCESSING,
        0,
      );

      // Find appropriate processor
      const processor = worker["findProcessor"](processingMessage);
      if (!processor) {
        throw new Error(
          `No processor found for operation: ${processingMessage.operation}, format: ${processingMessage.targetFormat}`,
        );
      }

      // Get input file path from message (using standard convention)
      const inputKey = `uploads/${processingMessage.jobId}`;
      // TODO: Add inputKey to ProcessingMessage interface if you need it

      // Get the file from S3
      const originalBuffer = await dependencies.fileStorage.getFile(inputKey);
      dependencies.logger.info(
        `Retrieved file from S3: ${inputKey}, size: ${originalBuffer.length} bytes`,
      );

      await dependencies.jobStatusUpdater.updateStatus(
        processingMessage.jobId,
        JobStatus.PROCESSING,
        25,
      );

      // Process the file
      const result = await processor.process(originalBuffer, processingMessage);
      await dependencies.jobStatusUpdater.updateStatus(
        processingMessage.jobId,
        JobStatus.PROCESSING,
        75,
      );

      // Generate output key and upload processed file
      const outputPrefix =
        processingMessage.operation === "compress" ? "compressed" : "processed";
      const outputKey = `${outputPrefix}/${processingMessage.jobId}.${result.fileExtension}`;
      await dependencies.fileStorage.putFile(
        outputKey,
        result.buffer,
        result.contentType,
      );

      const downloadUrl =
        dependencies.fileStorage.generateDownloadUrl(outputKey);

      // Mark as completed
      await dependencies.jobStatusUpdater.updateStatus(
        processingMessage.jobId,
        JobStatus.COMPLETED,
        100,
        downloadUrl,
      );

      dependencies.logger.info(
        `Processing completed for job ${processingMessage.jobId}`,
        {
          operation: processingMessage.operation,
          targetFormat: processingMessage.targetFormat,
          outputSize: result.buffer.length,
          downloadUrl,
        },
      );
    } catch (error) {
      dependencies.logger.error(
        `Failed to process SQS message ${record.messageId}`,
        error,
      );

      // Try to parse message to get job ID for status update
      try {
        const processingMessage: ProcessingMessage = JSON.parse(record.body);
        if (processingMessage.jobId) {
          await dependencies.jobStatusUpdater.updateStatus(
            processingMessage.jobId,
            JobStatus.FAILED,
            0,
          );
        }
      } catch (parseError) {
        dependencies.logger.error(
          "Could not update job status due to parse error",
          parseError,
        );
      }

      // Re-throw to ensure the SQS message is not deleted (will be retried)
      throw error;
    }
  });

  // Wait for all messages to be processed
  try {
    await Promise.all(promises);
    dependencies.logger.info(
      `Successfully processed all ${event.Records.length} messages`,
    );
  } catch (error) {
    dependencies.logger.error("Failed to process some messages", error);
    throw error;
  }
};
