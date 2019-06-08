resource "aws_lb" "lambda_lb" {
  name            = "${var.name}-lambda-lb"
  internal        = "false"
  security_groups = ["${aws_security_group.lambda_lb_sg.id}"]
  subnets         = ["${aws_default_subnet.default_az1.id}", "${aws_default_subnet.default_az2.id}"]
  idle_timeout    = "3600"

  enable_deletion_protection = false

  tags {
    Name        = "lambda_lb"
    Description = "Application Load Balancer for pwsh lambda execution"
    ManagedBy   = "Terraform"
  }
}

output "alb_dns" {
  value = "${aws_lb.lambda_lb.dns_name}"
}

output "lb_dns" {
  value = "${aws_lb.lambda_lb.dns_name}"
}

resource "aws_lb_listener" "front_end_http" {
  load_balancer_arn = "${aws_lb.lambda_lb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.lambda-example.arn}"
    type             = "forward"
  }
}

resource "aws_security_group" "lambda_lb_sg" {
  description = "the alb security group that allows port 80 to the lambda lb"

  name = "${var.name}"

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
  name        = "${var.name}-lambda-tg"
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

  depends_on = ["aws_codepipeline.codepipeline", "aws_lb.lambda_lb"]
}

resource "aws_lb_target_group_attachment" "lambda" {
  target_group_arn = "${aws_lb_target_group.lambda-example.arn}"
  target_id        = "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.name}"
  depends_on       = ["aws_lambda_permission.with_lb"]
}
