# Create DB subnet group (no changes needed)
resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "mysql-subnet-group"
  subnet_ids = [
    for subnet in var.subnets :
    aws_subnet.subnets[subnet.name].id
    if subnet.type == "private"
  ]

  tags = {
    Name = "MySQL Subnet Group"
  }
}

# Update security group for MySQL
resource "aws_security_group" "rds_sg" {
  name        = "mysql-security-group"
  description = "Allow access to MySQL"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow MySQL access"
    from_port   = 3306  # MySQL default port
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]  # Restrict to VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mysql-security-group"
  }
}

# Create MySQL RDS instance (Free Tier eligible)
resource "aws_db_instance" "mysql_rds" {
  identifier             = "free-tier-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"          # Latest stable version
  instance_class         = "db.t3.micro"  # Free Tier eligible
  allocated_storage      = 20             # Max for Free Tier (GB)
  storage_type           = "gp2"
  db_name                = "mydatabase"   # Replace with your DB name
  username               = "admin"        # Replace with your username
  password               = var.db_password
  skip_final_snapshot    = true           # For dev (set to false in prod)
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  # Free Tier optimizations
  backup_retention_period = 0      # Disable backups (Free Tier limit: 1 snapshot)
  maintenance_window      = "Mon:00:00-Mon:03:00"
  deletion_protection     = false  # Disable for easier cleanup

  # Optional: Enable storage autoscaling (not Free Tier eligible)
  # max_allocated_storage = 100

  tags = {
    Environment = "dev"
  }
}

# Output the MySQL endpoint
output "mysql_endpoint" {
  value = aws_db_instance.mysql_rds.endpoint
}