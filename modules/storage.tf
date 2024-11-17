# Intermediate S3 Bucket for OpenSearch Backup
resource "aws_s3_bucket" "intermediate_bucket" {
  bucket = "firehose-intermediate-bucket"

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_acl" "intermediate_bucket_acl" {
  bucket = aws_s3_bucket.intermediate_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "intermediate_bucket_version" {
  bucket = aws_s3_bucket.intermediate_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "intermediate_bucket_configuration" {
  bucket = aws_s3_bucket.intermediate_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "AES256"
    }
  }
}

# Final S3 Bucket for Lambda
resource "aws_s3_bucket" "iot_data_bucket" {
  bucket = "iot-data-bucket"

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_acl" "iot_data_bucket_acl" {
  bucket = aws_s3_bucket.iot_data_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "iot_data_bucket_version" {
  bucket = aws_s3_bucket.iot_data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "iot_data_bucket_configuration" {
  bucket = aws_s3_bucket.iot_data_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "AES256"
    }
  }
}