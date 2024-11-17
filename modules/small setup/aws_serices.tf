variable "lambda_security_group_id" {}

# Lambda Function
resource "aws_lambda_function" "my_lambda" {
  function_name = "MyFunction"
  handler       = "index.handler"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "lambda_function.zip"  # Ensure the zip file is present
  timeout       = 30
  vpc_config {
    security_group_ids = [var.lambda_security_group_id]
    subnet_ids         =data.aws_subnets.private.ids
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "tag:Environment"
    values = ["private"]
  }
}


# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "LambdaExecutionRole"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# API Gateway
resource "aws_apigatewayv2_api" "http_api" {
  name          = "MyHTTPAPI"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.my_lambda.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# WAF (Web Application Firewall)
resource "aws_wafv2_web_acl" "api_waf" {
  name        = "APIWAF"
  scope       = "REGIONAL"
  default_action {
    allow {}
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "apiWAF"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      sampled_requests_enabled = true
      cloudwatch_metrics_enabled = true
      metric_name = "awsCommonRules"
    }
  }
}

# Associate WAF with API Gateway
resource "aws_wafv2_web_acl_association" "waf_apigw_assoc" {
  resource_arn = aws_apigatewayv2_api.http_api.execution_arn
  web_acl_arn  = aws_wafv2_web_acl.api_waf.arn
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/${aws_lambda_function.my_lambda.function_name}"
  retention_in_days = 14
}

# CloudTrail
resource "aws_cloudtrail" "main_trail" {
  name                          = "MainTrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true
}

resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "cloudtrail-logs-${random_string.bucket_suffix.result}"
}

resource "random_string" "bucket_suffix" {
  length  = 8
  upper   = false
  special = false
}

# Cognito User Pool
resource "aws_cognito_user_pool" "user_pool" {
  name = "MyUserPool"
}

output "lambda_function_arn" {
  value = aws_lambda_function.my_lambda.arn
}

output "api_gateway_invoke_url" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}
