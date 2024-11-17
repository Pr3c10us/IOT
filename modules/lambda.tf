# Null resource to run the build script in the lambda folder
resource "null_resource" "build_lambda" {
  provisioner "local-exec" {
    command     = "./lambda/build_lambda.sh"
    working_dir = path.module
  }
}

# Post-Delivery Lambda Function
resource "aws_lambda_function" "post_delivery_lambda" {
  function_name    = "post_delivery_processor"
  role             = aws_iam_role.lambda_post_delivery_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  filename         = "${path.module}/lambda/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/lambda_function.zip")

  environment {
    variables = {
      BUCKET_NAME    = aws_s3_bucket.iot_data_bucket.bucket
      DYNAMODB_TABLE = aws_dynamodb_table.data_table.name
    }
  }

  vpc_config {
    subnet_ids         = aws_subnet.private_subnet[*].id
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }

  depends_on = [null_resource.build_lambda]
}