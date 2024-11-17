# S3 Bucket for Athena Query Results
resource "aws_s3_bucket" "athena_results" {
  bucket = "athena-query-results-${random_string.bucket_suffix.result}"
  acl    = "private"
}

resource "random_string" "bucket_suffix" {
  length  = 8
  upper   = false
  number  = true
  special = false
}

# Athena Workgroup
resource "aws_athena_workgroup" "primary" {
  name = "primary"
  state = "ENABLED"
  configuration {
    enforce_workgroup_configuration = true
    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.id}/"
    }
  }
}

# IAM Role for Read-Only Access
resource "aws_iam_role" "athena_readonly_role" {
  name = "AthenaReadOnlyRole"

  assume_role_policy = data.aws_iam_policy_document.athena_assume_role.json
}

data "aws_iam_policy_document" "athena_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_iam_policy" "athena_readonly_policy" {
  name = "AthenaReadOnlyPolicy"

  policy = data.aws_iam_policy_document.athena_readonly_policy.json
}

data "aws_iam_policy_document" "athena_readonly_policy" {
  statement {
    actions = [
      "athena:GetWorkGroup",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:StartQueryExecution",
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "attach_athena_policy" {
  role       = aws_iam_role.athena_readonly_role.name
  policy_arn = aws_iam_policy.athena_readonly_policy.arn
}

data "aws_caller_identity" "current" {}
