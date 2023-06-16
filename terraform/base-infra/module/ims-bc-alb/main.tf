resource "aws_lb" "app_lb" {
  name = var.load_balancer_name
  internal = var.internal_alb
  load_balancer_type = "application"
  security_groups = [module.security_group_server.this_security_group_id]
  subnets = var.alb_subnet_ids

  enable_deletion_protection = var.deletion_protection

  access_logs {
    bucket = var.s3_log_bucket_name
    prefix = var.s3_log_prefix_name
    enabled = var.enable_alb_acces_logs
  }

  tags = {
    Name = var.alb_name_tag
    Environment = var.alb_environment
    Owner = var.alb_owner
  }
}

resource "aws_lb_target_group" "rnd_ci_https_instance_target_group" {
  name = var.rnd_ci_alb_target_group_name
  port = 443
  protocol = "HTTPS"
  vpc_id = var.alb_vpc_id
  deregistration_delay = 0
  target_type = "ip"
}

resource "aws_lb_target_group_attachment" "rnd_ci_target_group_attachment" {
  target_group_arn = aws_lb_target_group.rnd_ci_https_instance_target_group.arn
  target_id        = var.rnd_ci_target_ip
  port             = 443
  availability_zone = "all"
}

resource "aws_lb_target_group" "infrabuild_https_instance_target_group" {
  name = var.infrabuild_alb_target_group_name
  port = 443
  protocol = "HTTPS"
  vpc_id = var.alb_vpc_id
  deregistration_delay = 0
  target_type = "ip"
}

resource "aws_lb_target_group_attachment" "infrabuild_target_group_attachment" {
  target_group_arn = aws_lb_target_group.infrabuild_https_instance_target_group.arn
  target_id        = var.infrabuild_target_ip
  port             = 443
  availability_zone = "all"
}

resource "aws_lb_target_group" "rnd_artifacts_https_instance_target_group" {
  name = var.rnd_artifacts_alb_target_group_name
  port = 443
  protocol = "HTTPS"
  vpc_id = var.alb_vpc_id
  deregistration_delay = 0
  target_type = "ip"
}

resource "aws_lb_target_group_attachment" "rnd_artifacts_target_group_attachment" {
  target_group_arn = aws_lb_target_group.rnd_artifacts_https_instance_target_group.arn
  target_id        = var.rnd_artifacts_target_ip
  port             = 443
  availability_zone = "all"
}

resource "aws_lb_target_group" "https_instance_target_group" {
  name = var.sonar_alb_target_group_name
  port = 443
  protocol = "HTTPS"
  vpc_id = var.alb_vpc_id
  deregistration_delay = 0
  health_check {
    protocol = "HTTPS"
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "https_alb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.alb_certificate_arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.https_instance_target_group.arn

  }
}

resource "aws_lb_listener" "http_alb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener_rule" "forward_host_based_rule" {
  listener_arn = aws_lb_listener.https_alb_listener.arn

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.https_instance_target_group.arn
  }

  condition {
    host_header {
      values = var.sonar_alb_forward_host
    }
  }
}

resource "aws_lb_listener_rule" "rnd_ci_forward_host_based_rule" {
  listener_arn = aws_lb_listener.https_alb_listener.arn

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.rnd_ci_https_instance_target_group.arn
  }

  condition {
    host_header {
      values = var.rnd_ci_alb_forward_host
    }
  }
}

resource "aws_lb_listener_rule" "infrabuild_forward_host_based_rule" {
  listener_arn = aws_lb_listener.https_alb_listener.arn

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.infrabuild_https_instance_target_group.arn
  }

  condition {
    host_header {
      values = var.infrabuild_alb_forward_host
    }
  }
}

resource "aws_lb_listener_rule" "rnd_artifacts_forward_host_based_rule" {
  listener_arn = aws_lb_listener.https_alb_listener.arn

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.rnd_artifacts_https_instance_target_group.arn
  }

  condition {
    host_header {
      values = var.rnd_artifacts_alb_forward_host
    }
  }
}

resource "aws_lb_listener_rule" "health_check" {
  listener_arn = aws_lb_listener.https_alb_listener.arn

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "HEALTHY"
      status_code  = "200"
    }
  }

  condition {
    path_pattern {
      values = ["/health"]
    }
  }
}

module "security_group_client" {
  source = "terraform-aws-modules/security-group/aws"
  version = "3.3.0"
  name = "alb_client_sg"
  description = "alb security group for clients"
  vpc_id = var.alb_vpc_id
  computed_ingress_with_source_security_group_id = [{
      rule                     = "https-443-tcp"
      source_security_group_id = module.security_group_server.this_security_group_id
    }]
  ingress_with_cidr_blocks = [
    {
      rule = "https-443-tcp"
      cidr_blocks = "${var.rnd_ci_target_ip}/32"
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1
}

module "security_group_server" {
  source = "terraform-aws-modules/security-group/aws"
  version = "3.3.0"
  name = "alb_sg"
  description = "alb security group on the server side"
  vpc_id = var.alb_vpc_id
  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "https"
      cidr_blocks = "10.0.0.0/8"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "http"
      cidr_blocks = "10.0.0.0/8"
    }]
  computed_egress_with_source_security_group_id = [{
      rule                     = "https-443-tcp"
      source_security_group_id = module.security_group_client.this_security_group_id
    }
  ]
  egress_with_cidr_blocks = [
    {
      rule = "https-443-tcp"
      cidr_blocks = "${var.rnd_ci_target_ip}/32"
    },
    {
      rule = "https-443-tcp"
      cidr_blocks = "${var.infrabuild_target_ip}/32"
    },
    {
      rule = "https-443-tcp"
      cidr_blocks = "${var.rnd_artifacts_target_ip}/32"
    }
  ]
  number_of_computed_egress_with_source_security_group_id = 1

  # Workaround https://github.com/terraform-aws-modules/terraform-aws-security-group/issues/130
  egress_ipv6_cidr_blocks = []
}
