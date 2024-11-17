# outputs.tf

output "intermediate_bucket_name" {
  description = "Name of the intermediate S3 bucket for OpenSearch backups"
  value       = aws_s3_bucket.intermediate_bucket.bucket
}

output "iot_data_bucket_name" {
  description = "Name of the final S3 bucket for Lambda processing"
  value       = aws_s3_bucket.iot_data_bucket.bucket
}

output "opensearch_domain_endpoint" {
  description = "Endpoint of the OpenSearch Domain"
  value       = aws_opensearch_domain.opensearch.endpoint
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB Table"
  value       = aws_dynamodb_table.data_table.name
}

output "lambda_post_delivery_arn" {
  description = "ARN of the Post-Delivery Lambda Function"
  value       = aws_lambda_function.post_delivery_lambda.arn
}

output "kinesis_stream_arn" {
  description = "ARN of the Kinesis Data Stream"
  value       = aws_kinesis_stream.data_stream.arn
}

output "grafana_workspace_url" {
  description = "URL of the AWS Managed Grafana workspace"
  value       = aws_grafana_workspace.grafana.endpoint
}
