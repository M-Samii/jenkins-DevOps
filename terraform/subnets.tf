resource "aws_subnet" "subnets" {
  for_each                = { for subnet in var.subnets : subnet.name => subnet }
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = each.value.type == "public" ? true : false
  availability_zone       = "${var.region}${each.value.az}"
  tags                    = { "Name" = each.value.name }
}