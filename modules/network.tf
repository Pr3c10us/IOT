# 1. Data Sources
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

# 2. Create a new VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main_vpc"
  }
}

# 3. Create Three Private Subnets
resource "aws_subnet" "private_subnet" {
  count             = 3
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "private_subnet_${count.index + 1}"
  }
}

# 4. Create Route Tables for Each Private Subnet
resource "aws_route_table" "private_route_table" {
  count  = 3
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "private_route_table_${count.index + 1}"
  }
}

# 5. Associate Each Private Subnet with Its Route Table
resource "aws_route_table_association" "private_route_table_association" {
  count          = 3
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}

# 6. VPC Endpoint for Amazon DynamoDB (Gateway Endpoint)
resource "aws_vpc_endpoint" "dynamodb_endpoint" {
  vpc_id            = aws_vpc.main_vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_endpoint_type = "Gateway"

  route_table_ids = aws_route_table.private_route_table[*].id

  tags = {
    Name = "dynamodb_vpc_endpoint"
  }
}

# 7. VPC Endpoint for Amazon S3 (Gateway Endpoint)
resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = aws_vpc.main_vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = aws_route_table.private_route_table[*].id

  tags = {
    Name        = "s3_vpc_endpoint"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# 8. Security Group for Athena Interface Endpoint
resource "aws_security_group" "athena_endpoint_sg" {
  name        = "athena_endpoint_sg"
  description = "Security group for Athena VPC Interface Endpoint"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Adjust based on your VPC CIDR
    description = "Allow HTTPS traffic from within VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "athena_endpoint_sg"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# 9. VPC Endpoint for Amazon Athena (Interface Endpoint)
resource "aws_vpc_endpoint" "athena_endpoint" {
  vpc_id            = aws_vpc.main_vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.athena"
  vpc_endpoint_type = "Interface"

  subnet_ids            = aws_subnet.private_subnet[*].id
  security_group_ids    = [aws_security_group.athena_endpoint_sg.id]
  private_dns_enabled   = true
  dns_entry {
    dns_name = "athena.${data.aws_region.current.name}.amazonaws.com"
  }

  tags = {
    Name        = "athena_vpc_endpoint"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# 10. Security Group for OpenSearch Interface Endpoint
resource "aws_security_group" "opensearch_endpoint_sg" {
  name        = "opensearch_endpoint_sg"
  description = "Security group for OpenSearch VPC Interface Endpoint"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Adjust based on your VPC CIDR
    description = "Allow HTTPS traffic from within VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "opensearch_endpoint_sg"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# 11. VPC Endpoint for Amazon OpenSearch Service (Interface Endpoint)
resource "aws_vpc_endpoint" "opensearch_endpoint" {
  vpc_id            = aws_vpc.main_vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.es" # For OpenSearch
  vpc_endpoint_type = "Interface"

  subnet_ids            = aws_subnet.private_subnet[*].id
  security_group_ids    = [aws_security_group.opensearch_endpoint_sg.id]
  private_dns_enabled   = true
  dns_entry {
    dns_name = "search.${data.aws_region.current.name}.amazonaws.com"
  }

  tags = {
    Name        = "opensearch_vpc_endpoint"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

