resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = [
    for subnet in var.subnets :
    aws_subnet.subnets[subnet.name].id
    if subnet.type == "public"
  ][0]

  tags = {
    Name = "gw NAT"
  }

}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
}