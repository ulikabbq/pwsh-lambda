resource "aws_s3_bucket" "code_artifacts" {
  bucket = "pwsh-lambda-${random_string.random.result}"
  acl    = "private"
}

resource "aws_iam_role" "codepipeline" {
  name = "ulikabbq-lambda-test-pipeline"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "ulikabbq-lambda-test-codepipeline_policy"
  role = "${aws_iam_role.codepipeline.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
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
        "Effect": "Allow",
        "Action": [
            "codedeploy:CreateDeployment",
            "codedeploy:GetApplicationRevision",
            "codedeploy:GetDeployment",
            "codedeploy:GetDeploymentConfig",
            "codedeploy:RegisterApplicationRevision"
        ],
        "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "${aws_codebuild_project.codebuild_project.arn}"
    }
  ]
}
EOF
}

// code pipeline 
resource "aws_codepipeline" "codepipeline" {
  name     = "ulikabbq-lambda-test"
  role_arn = "${aws_iam_role.codepipeline.arn}"

  artifact_store {
    location = "${aws_s3_bucket.code_artifacts.bucket}"
    type     = "S3"
  }

  // code pull from github
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["lambda"]

      configuration = {
        Owner  = "ulikabbq"
        Repo   = "pwsh-lambda"
        Branch = "master"
      }
    }
  }

  // codebuild the lambda
  stage {
    name = "Build-Lambda"

    action {
      name            = "Build-Lambda"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["lambda"]
      version         = "1"

      configuration = {
        ProjectName = "${aws_codebuild_project.codebuild_project.id}"
      }
    }
  }
}
