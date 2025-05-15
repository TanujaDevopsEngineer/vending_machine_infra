resource "aws_security_group" "alb" {
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0", "10.1.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "vending-machine-alb-sg"
  }
  depends_on = [var.vpc_id]
}

resource "aws_lb" "main" {
  name               = "vending-machine-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
  depends_on         = [aws_security_group.alb]
}

resource "aws_lb_target_group" "main" {
  name        = "vending-machine-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/beverages"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  depends_on = [aws_lb.main]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
  depends_on = [aws_lb_target_group.main]
}

resource "aws_lb_listener_rule" "deny_ingredients" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100
  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Access Denied"
      status_code  = "403"
    }
  }
  condition {
    path_pattern {
      values = ["/ingredients", "/ingredients/*"]
    }
  }
  depends_on = [aws_lb_listener.http]
}