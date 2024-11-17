resource "aws_route53_zone" "example_com" {
  name = "example.com"
}

resource "aws_route53_record" "api_gateway" {
  zone_id = aws_route53_zone.example_com.zone_id
  name    = "logs"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.api_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.api_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}
