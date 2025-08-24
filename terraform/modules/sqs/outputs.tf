output "queue_name" {
  description = "Name of the SQS queue"
  value       = aws_sqs_queue.main.name
}

output "queue_id" {
  description = "ID of the SQS queue"
  value       = aws_sqs_queue.main.id
}

output "queue_arn" {
  description = "ARN of the SQS queue"
  value       = aws_sqs_queue.main.arn
}

output "queue_url" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.main.url
}

output "dead_letter_queue_name" {
  description = "Name of the dead letter queue"
  value       = aws_sqs_queue.dead_letter.name
}

output "dead_letter_queue_id" {
  description = "ID of the dead letter queue"
  value       = aws_sqs_queue.dead_letter.id
}

output "dead_letter_queue_arn" {
  description = "ARN of the dead letter queue"
  value       = aws_sqs_queue.dead_letter.arn
}

output "dead_letter_queue_url" {
  description = "URL of the dead letter queue"
  value       = aws_sqs_queue.dead_letter.url
}
