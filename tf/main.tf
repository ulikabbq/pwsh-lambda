provider "aws" {
  region = "${var.region}"

  version = ">=2.3.0"
}

data "aws_caller_identity" "current" {}

resource "random_string" "random" {
  length  = 16
  special = false
}
