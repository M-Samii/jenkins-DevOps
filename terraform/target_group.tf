resource "aws_lb_target_group" "node" {
  name        = "node-tg"
  port        = 80 # Port your instances listen on (e.g., HTTP)
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id # Replace with your VPC ID if needed
  target_type = "instance"      # Direct traffic to EC2 instances

  health_check {
    path                = "/db" # Health check endpoint
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    matcher             = "200-399"
  }
}