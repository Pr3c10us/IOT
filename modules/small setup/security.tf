variable "developer_ips" {
  type = list(string)
  default = ["0.0.0.0"]
}

# Security Group for Lambda Functions
resource "aws_security_group" "lambda_sg" {
  name        = "LambdaSG"
  description = "Security group for Lambda functions"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "LambdaSG"
  }
}

# Security Group for Developers
resource "aws_security_group" "developer_sg" {
  name        = "DeveloperSG"
  description = "Security group for developer access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22  # Assuming SSH access
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.developer_ips
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DeveloperSG"
  }
}

output "lambda_security_group_id" {
  value = aws_security_group.lambda_sg.id
}
