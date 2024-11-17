resource "aws_cloudfront_distribution" "api_distribution" {
  origin {
    domain_name = aws_api_gateway_rest_api.iot_api.execution_arn
    origin_id   = "APIGatewayOrigin"
  }

  enabled             = true
  default_root_object = ""

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "APIGatewayOrigin"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_route53_record" "api_record" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "api.example.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.api_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.api_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_zone" "primary" {
  name = "example.com"
}
