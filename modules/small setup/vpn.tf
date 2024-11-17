# Customer Gateway (On-premises)
resource "aws_customer_gateway" "customer_gw" {
  bgp_asn    = 65000
  ip_address = "198.51.100.0"  # Replace with your on-premises public IP
  type       = "ipsec.1"
  tags = {
    Name = "CustomerGateway"
  }
}

# Virtual Private Gateway (AWS Side)
resource "aws_vpn_gateway" "vpn_gw" {
  vpc_id = var.vpc_id
  tags = {
    Name = "VPNGateway"
  }
}

# VPN Connection
resource "aws_vpn_connection" "vpn_connection" {
  vpn_gateway_id  = aws_vpn_gateway.vpn_gw.id
  customer_gateway_id = aws_customer_gateway.customer_gw.id
  type            = "ipsec.1"
  static_routes_only = true
  tags = {
    Name = "VPNConnection"
  }
}

# VPN Connection Route
resource "aws_vpn_connection_route" "vpn_route" {
  vpn_connection_id = aws_vpn_connection.vpn_connection.id
  destination_cidr_block = "0.0.0.0/0"
}
