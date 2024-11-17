# iam.tf

# IAM Role for Firehose (Used by Both Firehose Streams)
resource "aws_iam_role" "firehose_role" {
  name = "firehose_role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }]
  })
}

# IAM Policy for Firehose
resource "aws_iam_role_policy" "firehose_policy" {
  name = "firehose_policy"
  role = aws_iam_role.firehose_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      # S3 Permissions for intermediate_bucket
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ],
        "Resource": [
          "${aws_s3_bucket.intermediate_bucket.arn}/*",
          "${aws_s3_bucket.intermediate_bucket.arn}"
        ]
      },
      # S3 Permissions for iot_data_bucket
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ],
        "Resource": [
          "${aws_s3_bucket.iot_data_bucket.arn}/*",
          "${aws_s3_bucket.iot_data_bucket.arn}"
        ]
      },
      # OpenSearch Permissions
      {
        "Effect": "Allow",
        "Action": [
          "es:DescribeElasticsearchDomain",
          "es:DescribeElasticsearchDomains",
          "es:DescribeElasticsearchDomainConfig",
          "es:ListDomainNames",
          "es:ESHttpPost",
          "es:ESHttpPut",
          "es:ESHttpDelete",
          "es:ESHttpGet"
        ],
        "Resource": "${aws_opensearch_domain.opensearch.arn}/*"
      },
      # Lambda Permissions for Data Transformation (Optional)
      {
        "Effect": "Allow",
        "Action": [
          "lambda:InvokeFunction"
        ],
        "Resource": "${aws_lambda_function.firehose_transform_lambda.arn}"
      },
      # Lambda Permissions for Post-Delivery Processing
      {
        "Effect": "Allow",
        "Action": [
          "lambda:InvokeFunction"
        ],
        "Resource": "${aws_lambda_function.post_delivery_lambda.arn}"
      },
      # CloudWatch Logs Permissions
      {
        "Effect": "Allow",
        "Action": [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ],
        "Resource": "arn:aws:logs:*:*:*"
      },
      # S3 Backup Permissions for intermediate_bucket
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetBucketLocation"
        ],
        "Resource": [
          "${aws_s3_bucket.intermediate_bucket.arn}/*",
          "${aws_s3_bucket.intermediate_bucket.arn}"
        ]
      },
      # IAM PassRole
      {
        "Effect": "Allow",
        "Action": "iam:PassRole",
        "Resource": "${aws_iam_role.firehose_role.arn}"
      }
    ]
  })
}

# IAM Role for Post-Delivery Lambda
resource "aws_iam_role" "lambda_post_delivery_role" {
  name = "lambda_post_delivery_role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for Post-Delivery Lambda
resource "aws_iam_role_policy" "lambda_post_delivery_policy" {
  name = "lambda_post_delivery_policy"
  role = aws_iam_role.lambda_post_delivery_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      # Permissions to read from iot_data_bucket
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource": [
          "${aws_s3_bucket.iot_data_bucket.arn}/*",
          "${aws_s3_bucket.iot_data_bucket.arn}"
        ]
      },
      # Permissions to write to DynamoDB
      {
        "Effect": "Allow",
        "Action": [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:GetItem",
          "dynamodb:BatchWriteItem"
        ],
        "Resource": "${aws_dynamodb_table.data_table.arn}"
      },
      # CloudWatch Logs Permissions
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role" "glue_role" {
  name = "glue_execution_role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "glue.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "glue_policy" {
  role = aws_iam_role.glue_role.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Effect": "Allow",
        "Resource": [
          aws_s3_bucket.intermediate_bucket.arn,
          aws_s3_bucket.iot_data_bucket.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role" "grafana_role" {
  name = "grafana_role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "grafana.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "grafana_policy" {
  role = aws_iam_role.grafana_role.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "athena:*",
          "s3:*"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  })
}
