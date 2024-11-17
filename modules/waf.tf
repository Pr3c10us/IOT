resource "aws_wafv2_web_acl" "waf" {
  name        = "LogAPIFirewall"
  scope       = "REGIONAL"
  description = "WAF for the Log API Gateway"

  default_action {
    allow {}
  }

  rule {
    name     = "BlockSQLInjection"
    priority = 0

    statement {
      sqli_match_statement {
        field_to_match {
          uri_path {}
        }

        text_transformations {
          priority = 0
          type     = "NONE"
        }
      }
    }

    action {
      block {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockSQLInjection"
      sampled_requests_enabled   = true
    }
  }
}

resource "aws_wafv2_web_acl_association" "api_gateway_waf" {
  resource_arn = aws_api_gateway_rest_api.log_api.execution_arn
  web_acl_arn  = aws_wafv2_web_acl.waf.arn
}
