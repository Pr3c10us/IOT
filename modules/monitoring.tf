resource "aws_cloudtrail" "main_trail" {
  name                          = "MainTrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
}

resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "my-cloudtrail-logs-bucket"
  acl    = "private"
}

resource "aws_opensearch_domain" "logs_domain" {
  domain_name           = "iot-logs-domain"
  engine_version        = "OpenSearch_1.0"
  cluster_config {
    instance_type = "m4.large.search"
    instance_count = 2
  }
}
