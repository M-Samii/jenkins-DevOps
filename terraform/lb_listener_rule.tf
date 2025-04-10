
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.test.arn # Reference your ALB
  port              = 80
  protocol          = "HTTP"

  # Default action (e.g., return 404 for unmatched paths)
    default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.node.arn
  }

  }

