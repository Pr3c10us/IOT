resource "aws_api_gateway_rest_api" "iot_api" {
  name = "IoTDataAPI"
}

resource "aws_api_gateway_resource" "data_resource" {
  rest_api_id = aws_api_gateway_rest_api.iot_api.id
  parent_id   = aws_api_gateway_rest_api.iot_api.root_resource_id
  path_part   = "data"
}

resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.iot_api.id
  resource_id   = aws_api_gateway_resource.data_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.iot_api.id
  resource_id = aws_api_gateway_resource.data_resource.id
  http_method = aws_api_gateway_method.get_method.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri         = aws_lambda_function.process_iot_data.invoke_arn
}

resource "aws_waf_web_acl" "api_waf" {
  name        = "APIWAF"
  metric_name = "APIWAF"

  default_action {
    type = "ALLOW"
  }

  rules {
    name     = "Rule1"
    priority = 1
    action {
      type = "BLOCK"
    }
    override_action {
      type = "NONE"
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
      metric_name = "WAFRule"
    }
  }
}
