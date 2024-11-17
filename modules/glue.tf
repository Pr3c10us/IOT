# Glue Crawler for S3 Data Cataloging
resource "aws_glue_crawler" "s3_crawler" {
  name = "s3_crawler"
  database_name = "s3_data_catalog"
  role = aws_iam_role.glue_role.arn

  s3_target {
    path = aws_s3_bucket.iot_data_bucket.arn
  }
}
