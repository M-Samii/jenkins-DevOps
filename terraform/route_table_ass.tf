resource "aws_route_table_association" "routes_association" {

  for_each       = { for subnet in aws_subnet.subnets : subnet.tags.Name => subnet }
  subnet_id      = each.value.id
  route_table_id = each.value.map_public_ip_on_launch ? aws_route_table.public_route.id : aws_route_table.private_route.id
}
