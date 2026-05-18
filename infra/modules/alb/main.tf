resource "aws_security_group" "alb" {
  #checkov:skip=CKV_AWS_260:Public HTTP access is allowed in dev for external ALB testing; production will enforce HTTPS and restricted ingress.
  #checkov:skip=CKV_AWS_382:Broad outbound access is temporarily allowed in dev to simplify connectivity.

  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Allow HTTP traffic to ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_lb" "app" {
  #checkov:skip=CKV_AWS_2:HTTPS is deferred in dev to avoid ACM and domain configuration during early environment testing.
  #checkov:skip=CKV_AWS_91:ALB access logging is deferred in dev to avoid additional S3 logging infrastructure.
  #checkov:skip=CKV_AWS_150:Deletion protection is disabled in dev to allow repeated destroy and rebuild testing.
  #checkov:skip=CKV2_AWS_28:WAF is deferred in dev to keep the environment lightweight; production will attach AWS WAF to the public ALB.

  name                       = "${var.project_name}-${var.environment}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = var.public_subnet_ids
  drop_invalid_header_fields = true
  enable_deletion_protection = false

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "app" {
  #checkov:skip=CKV_AWS_378:HTTP is used between the dev ALB and ECS service to simplify testing; production will use HTTPS/TLS where appropriate.
  #checkov:skip=CKV2_AWS_20:HTTP to HTTPS redirection is deferred in dev because HTTPS is not configured until production.

  name        = "${var.project_name}-${var.environment}-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-tg"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_lb_listener" "http" {
  #checkov:skip=CKV_AWS_2:Dev ALB uses HTTP to avoid ACM and domain setup; production will use HTTPS.
  #checkov:skip=CKV_AWS_103:TLS policy is not configured in dev because this listener uses HTTP; production HTTPS listener will enforce TLS 1.2 or higher.
  #checkov:skip=CKV_AWS_378:Dev ALB listener uses HTTP for simple external testing; production will use HTTPS.
  #checkov:skip=CKV2_AWS_20:HTTP to HTTPS redirect is deferred in dev because HTTPS is not configured until production.

  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}