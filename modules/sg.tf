# security_groups.tf

# Security Group for Lambda
resource "aws_security_group" "lambda_sg" {
  name        = "lambda_sg"
  description = "Security group for Lambda to access DynamoDB via VPC endpoint"
  vpc_id      = aws_vpc.main_vpc.id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Typically, no inbound rules are needed for Lambda
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Adjust based on your VPC CIDR
    description = "Allow outbound HTTPS traffic to VPC endpoint"
  }

  tags = {
    Name = "lambda_sg"
  }
}
