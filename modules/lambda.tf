# Null resource to run the build script in the lambda folder
# resource "null_resource" "build_lambda" {
#   # Add triggers to rebuild when source code changes
#   triggers = {
#     source_code_hash = filemd5("${path.module}/lambda/lambda_function.py")
#     requirements_hash = filemd5("${path.module}/lambda/requirements.txt")
#     build_script_hash = filemd5("${path.module}/lambda/build_lambda.sh")
#   }
#
#   provisioner "local-exec" {
#     command     = "chmod +x ./lambda/build_lambda.sh && ./lambda/build_lambda.sh"
#     working_dir = path.module
#   }
# }

# Install dependencies if needed
resource "null_resource" "install_dependencies" {
  triggers = {
    requirements_hash = filemd5("${path.module}/lambda/requirements.txt")
  }

  provisioner "local-exec" {
    command = "pip install --target ${path.module}/lambda -r ${path.module}/lambda/requirements.txt"
  }
}

# Create zip with dependencies included
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda/lambda_function.zip"
  excludes    = ["lambda_function.zip", "build_lambda.sh", "requirements.txt"]

  depends_on = [null_resource.install_dependencies]
}

# Post-Delivery Lambda Function
resource "aws_lambda_function" "post_delivery_lambda" {
  function_name    = "post_delivery_processor"
  role             = aws_iam_role.lambda_post_delivery_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

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
}