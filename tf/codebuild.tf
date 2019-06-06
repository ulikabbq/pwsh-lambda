resource "aws_iam_role" "codebuild_lambda" {
  name = "ulikabbq-lambda-test-codebuild"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_lambda" {
  role = "${aws_iam_role.codebuild_lambda.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:*"
      ],
      "Resource": ["*"]
    },
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:Put*"
      ],
      "Resource": [
        "${aws_s3_bucket.code_artifacts.arn}",
        "${aws_s3_bucket.code_artifacts.arn}/*"
      ]
    },
    {
      "Effect":"Allow",
      "Action": [
        "lambda:GetFunctionConfiguration",
        "lambda:CreateFunction",
        "lambda:UpdateFunctionCode",
        "lambda:UpdateFunctionConfiguration",
        "iam:GetRole",
        "iam:PassRole"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
POLICY
}

data "template_file" "buildspec" {
  template = "${file("${path.module}/buildspec.tpl")}"

  vars {
    script   = "${var.script}"
    name     = "${var.name}"
    region   = "${var.region}"
    iam_role = "${aws_iam_role.iam_for_lambda.id}"
  }
}

resource "aws_codebuild_project" "codebuild_project" {
  name          = "lambda-test-ulikabbq"
  description   = "codebuild to publish the lambda"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild_lambda.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/dot-net:core-2.1"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${data.template_file.buildspec.rendered}"
  }
}
