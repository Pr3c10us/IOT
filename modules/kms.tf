resource "aws_kms_key" "log_key" {
  description = "Log encryption key for S3 bucket"
  tags = {
    Name = "LogEncryptionKey"
  }
}

resource "aws_kms_key" "iot_key" {
  description = "IoT key for secure data encryption"
  tags = {
    Name = "IoTEncryptionKey"
  }
}

resource "aws_kms_key" "api_gateway_key" {
  description = "API Gateway encryption key"
  tags = {
    Name = "APIGatewayEncryptionKey"
  }
}
