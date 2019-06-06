resource "aws_lb" "fastly-origin" {
  name            = "fastly-origin"
  internal        = "false"
  security_groups = ["${aws_security_group.origin_lb.id}"]
  subnets         = ["${module.vpc.public_subnets}"]
  idle_timeout    = "3600"

  enable_deletion_protection = false

  tags {
    Name        = "fastly-origin"
    Description = "Application Load Balancer for fastly-origin"
    ManagedBy   = "Terraform"
  }
}

output "lb_dns" {
  value = "${aws_lb.fastly-origin.dns_name}"
}

resource "aws_lb_listener" "front_end_http" {
  load_balancer_arn = "${aws_lb.fastly-origin.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.fastly_blue.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "fastly_blue" {
  name                 = "fastly-blue"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "${module.vpc.vpc_id}"
  target_type          = "ip"
  deregistration_delay = 30

  health_check {
    interval            = 10
    path                = "/"
    port                = "80"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags {
    Name        = "fastly-blue-tg"
    Description = "Target Group for Fargate Fastly"
    ManagedBy   = "Terraform"
  }
}

resource "aws_lb_target_group" "fastly_green" {
  name                 = "fastly-green"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "${module.vpc.vpc_id}"
  target_type          = "ip"
  deregistration_delay = 30

  health_check {
    interval            = 10
    path                = "/"
    port                = "80"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags {
    Name        = "fastly-green-tg"
    Description = "Target Group for Fargate Fastly"
    ManagedBy   = "Terraform"
  }
}

resource "aws_security_group" "origin_lb" {
  description = "the alb security group that allows port 80"

  vpc_id = "${module.vpc.vpc_id}"
  name   = "fastly-origin"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// lambda tg 
resource "aws_lb_target_group" "lambda-example" {
  name        = "lambda-tg"
  target_type = "lambda"

  lambda_multi_value_headers_enabled = false
}

resource "aws_lb_listener_rule" "lambda" {
  listener_arn = "${aws_lb_listener.front_end_http.arn}"
  priority     = "26"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.lambda-example.id}"
  }

  condition {
    field  = "path-pattern"
    values = ["/lambda/*"]
  }
}

resource "aws_lambda_permission" "with_lb" {
  statement_id  = "AllowExecutionFromlb"
  action        = "lambda:InvokeFunction"
  function_name = "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.name}"
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = "${aws_lb_target_group.lambda-example.arn}"
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = "${aws_lb_target_group.lambda-example.arn}"
  target_id        = "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.name}"
  depends_on       = ["aws_lambda_permission.with_lb"]
}
