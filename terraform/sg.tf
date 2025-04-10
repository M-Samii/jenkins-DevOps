resource "aws_security_group" "public_sg" {
  name        = "allow ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_8080_ipv4" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

resource "aws_vpc_security_group_egress_rule" "allow_outbound_public" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}


resource "aws_security_group" "private_sg" {
  name        = "allow ssh private"
  description = "Allow ssh inbound traffic for only vpc cidr"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "allow_ssh_private"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_2" {
  security_group_id = aws_security_group.private_sg.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_3000_ipv4_2" {
  security_group_id = aws_security_group.private_sg.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}


resource "aws_vpc_security_group_egress_rule" "allow_outbound_private" {
  security_group_id = aws_security_group.private_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}