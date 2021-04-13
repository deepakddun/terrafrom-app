provider "aws" {
  region = "us-east-2"
}

resource "aws_eip" "aws_eip_test" {
  vpc = true
}