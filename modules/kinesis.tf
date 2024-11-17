# Kinesis Data Stream
resource "aws_kinesis_stream" "data_stream" {
  name             = "data_stream"
  shard_count      = 2
  retention_period = 24 # Hours

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Firehose Delivery Stream to OpenSearch
resource "aws_kinesis_firehose_delivery_stream" "firehose_opensearch" {
  name        = "firehose-to-opensearch"
  destination = "opensearch"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.data_stream.arn
    role_arn           = aws_iam_role.firehose_role.arn
  }

  opensearch_configuration {
    role_arn              = aws_iam_role.firehose_role.arn
    domain_arn            = aws_opensearch_domain.opensearch.arn
    index_name            = "iot"
    type_name             = "_doc"
    index_rotation_period = "OneDay"

    s3_backup_mode = "FailedDocumentsOnly"
    s3_configuration {
      role_arn           = aws_iam_role.firehose_role.arn
      bucket_arn         = aws_s3_bucket.intermediate_bucket.arn
      compression_format = "UNCOMPRESSED"
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Firehose Delivery Stream to S3 and Lambda
resource "aws_kinesis_firehose_delivery_stream" "firehose_s3_and_lambda" {
  name        = "firehose-to-s3-and-lambda"
  destination = "s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.data_stream.arn
    role_arn           = aws_iam_role.firehose_role.arn
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
