# Get the latest Ubuntu 24.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


# EC2 Instances
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = [
    for subnet in var.subnets :
    aws_subnet.subnets[subnet.name].id
    if subnet.type == "public"
  ][0]

  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  associate_public_ip_address = true
  key_name                    = "mykey" 

  tags = {
    Name = "bastion-host"
  }
}

resource "aws_instance" "node_app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"

  subnet_id              = [
    for subnet in var.subnets :
    aws_subnet.subnets[subnet.name].id
    if subnet.type == "private"
  ][0]

  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = "mykey" 
  iam_instance_profile = aws_iam_instance_profile.ecr_access_profile.name

  tags = {
    Name = "node_app"
  }
}

resource "aws_instance" "jenkins_slave" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = [
    for subnet in var.subnets :
    aws_subnet.subnets[subnet.name].id
    if subnet.type == "private"
  ][0]

  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = "mykey"
  iam_instance_profile = aws_iam_instance_profile.ecr_access_profile.name

  tags = {
    Name = "jenkins_slave"
  }
}

# Target Group Attachment (for node_app)
resource "aws_lb_target_group_attachment" "tg_attachment" {
  target_group_arn = aws_lb_target_group.node.arn
  target_id        = aws_instance.node_app.id
  port             = 80
}

# Outputs
output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "node_app_ip" {
  description = "Private IP of node app instance"
  value       = aws_instance.node_app.private_ip
}

output "jenkins_slave_ip" {
  description = "Private IP of the jenkins slave instance"
  value       = aws_instance.jenkins_slave.private_ip
}