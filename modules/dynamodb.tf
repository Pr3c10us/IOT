# DynamoDB Table
resource "aws_dynamodb_table" "data_table" {
  name         = "data_table"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }

  hash_key = "id"

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
