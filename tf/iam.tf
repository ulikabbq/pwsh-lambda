// iam for lambda
resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.name}-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "iam_policy" {
  name = "${var.name}-lambda-policy"
  role = "${aws_iam_role.iam_for_lambda.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "ssm:*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect":"Allow",
      "Action": [
        "codepipeline:*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect":"Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams",
        "logs:GetLogEvents",
        "logs:*" 
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect":"Allow",
      "Action": [
        "autoscaling:Describe*",
        "ec2:Describe*",
        "ecs:*",
        "s3:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}
