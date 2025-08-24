output "convert_function_name" {
  description = "Name of the convert Lambda function"
  value       = aws_lambda_function.convert.function_name
}

output "convert_function_arn" {
  description = "ARN of the convert Lambda function"
  value       = aws_lambda_function.convert.arn
}

output "compress_function_name" {
  description = "Name of the compress Lambda function"
  value       = aws_lambda_function.compress.function_name
}

output "compress_function_arn" {
  description = "ARN of the compress Lambda function"
  value       = aws_lambda_function.compress.arn
}

output "process_function_name" {
  description = "Name of the process Lambda function"
  value       = aws_lambda_function.process.function_name
}

output "process_function_arn" {
  description = "ARN of the process Lambda function"
  value       = aws_lambda_function.process.arn
}

output "lambda_log_groups" {
  description = "CloudWatch log groups for Lambda functions"
  value = {
    convert  = aws_cloudwatch_log_group.convert.name
    compress = aws_cloudwatch_log_group.compress.name
    process  = aws_cloudwatch_log_group.process.name
  }
}
