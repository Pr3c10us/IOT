resource "aws_opensearch_domain" "opensearch" {
  domain_name    = "data-opensearch"
  engine_version = "OpenSearch_1.0"

  cluster_config {
    instance_type = "t3.small.search"
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }

  access_policies = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "${aws_iam_role.firehose_role.arn}"
        },
        "Action": [
          "es:ESHttpPost",
          "es:ESHttpPut",
          "es:ESHttpDelete",
          "es:ESHttpGet"
        ],
        "Resource": "${aws_opensearch_domain.opensearch.arn}/*"
      }
    ]
  })

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
