# Athena Workgroup
resource "aws_athena_workgroup" "athena_workgroup" {
  name = "analytics-workgroup"
}

# Managed Grafana
resource "aws_grafana_workspace" "grafana" {
  name  = "analytics-grafana"
  role_arn = aws_iam_role.grafana_role.arn
}

# IAM Roles and Policies
resource "aws_iam_role" "firehose_role" {
  name = "firehose_role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "firehose.amazonaws.com"
        }
      }
    ]
  })
}