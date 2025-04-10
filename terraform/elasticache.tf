# Create Elasticache subnet group
resource "aws_elasticache_subnet_group" "free_tier_cache" {
  name = "free-tier-cache-subnet-group"
  subnet_ids = [
    for subnet in var.subnets :
    aws_subnet.subnets[subnet.name].id
    if subnet.type == "private"
  ]
}

# Security group for Elasticache
resource "aws_security_group" "cache_sg" {
  name        = "free-tier-cache-sg"
  description = "Allow access to Redis"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow Redis access"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "free-tier-cache-sg"
  }
}

# Free-tier eligible Redis cache cluster
resource "aws_elasticache_cluster" "free_tier_redis" {
  cluster_id           = "free-tier-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro" # Free-tier eligible
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.2"
  port                 = 6379
  security_group_ids   = [aws_security_group.cache_sg.id]
  subnet_group_name    = aws_elasticache_subnet_group.free_tier_cache.name

  # transit_encryption_enabled             = true
  # Free-tier optimized settings
  snapshot_retention_limit = 0 # Disable automatic backups
  maintenance_window       = "mon:00:00-mon:03:00"

  tags = {
    Environment = "dev"
    FreeTier    = "true"
  }
}

# Output connection details
output "redis_endpoint" {
  value = aws_elasticache_cluster.free_tier_redis.cache_nodes[0].address
}