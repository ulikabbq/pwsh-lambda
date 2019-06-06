provider "aws" {
  region = "${var.region}"

  version = ">=2.3.0"
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "${var.region}a"
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "${var.region}b"
}

data "aws_caller_identity" "current" {}

resource "random_integer" "priority" {
  min = 1
  max = 99999
}
