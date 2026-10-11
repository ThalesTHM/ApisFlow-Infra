locals {
  name  = "${var.project}-${var.environment}"
  count = var.enabled ? 1 : 0
  https = var.certificate_arn != ""
}

resource "aws_lb" "this" {
  count = local.count

  name               = local.name
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "backend" {
  count = local.count

  name        = "${local.name}-backend"
  port        = var.backend_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  deregistration_delay = 30

  health_check {
    path                = var.backend_health_path
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group" "frontend" {
  count = local.count

  name        = "${local.name}-frontend"
  port        = var.frontend_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  deregistration_delay = 30

  health_check {
    path    = "/"
    matcher = "200"
  }
}

# Sem certificado (ainda sem domínio), o ALB atende só em HTTP na porta 80.
# Com certificate_arn, a 80 redireciona para a 443.
resource "aws_lb_listener" "http" {
  count = local.count

  load_balancer_arn = aws_lb.this[0].arn
  port              = 80
  protocol          = "HTTP"

  dynamic "default_action" {
    for_each = local.https ? [1] : []

    content {
      type = "redirect"

      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = local.https ? [] : [1]

    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.frontend[0].arn
    }
  }
}

resource "aws_lb_listener" "https" {
  count = var.enabled && local.https ? 1 : 0

  load_balancer_arn = aws_lb.this[0].arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend[0].arn
  }
}

resource "aws_lb_listener_rule" "api" {
  count = local.count

  listener_arn = local.https ? aws_lb_listener.https[0].arn : aws_lb_listener.http[0].arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend[0].arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}
