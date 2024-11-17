variable "vpc_id" {}

# Direct Connect Gateway
resource "aws_dx_gateway" "dx_gateway" {
  name            = "DXGateway"
  amazon_side_asn = 64512
}

# Virtual Interface (Assuming a private VIF)
resource "aws_dx_private_virtual_interface" "private_vif" {
  name                  = "PrivateVIF"
  connection_id         = "dxcon-xxxxxxx"  # Replace with your Direct Connect connection ID
  vlan                  = 4094            # Replace with your VLAN
  address_family        = "ipv4"
  bgp_asn               = 65000
  dx_gateway_id         = aws_dx_gateway.dx_gateway.id
}

# Associate DX Gateway with VPC
resource "aws_vpn_gateway" "vgw" {
  vpc_id = var.vpc_id
}

resource "aws_dx_gateway_association" "dx_gw_assoc" {
  dx_gateway_id        = aws_dx_gateway.dx_gateway.id
  vpn_gateway_id       = aws_vpn_gateway.vgw.id
}
