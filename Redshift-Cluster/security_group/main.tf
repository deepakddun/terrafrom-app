provider "aws" {
  region = "us-east-2"
}

data "aws_vpcs" "vpc_ids" {
  tags = {
    vpcType = "custom-vpc-terraform"
  }
}



locals {
  vpc_id = tolist(data.aws_vpcs.vpc_ids.ids)[0]
  cidr_block = ["10.200.0.0/16"]
}

resource "aws_security_group" "redshift_lambda_security_group" {
  name = "redshift_lambda_security_group"
  description = "This security group will be used for redshift and lambda"
  vpc_id = local.vpc_id

  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = local.cidr_block
  }

  egress {
    from_port = 0
    protocol = -1
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    CreatedBy = "Terraform",
    For = "Lambda-Redshift"
  }
}

output "vpc_id" {
  value = tolist(data.aws_vpcs.vpc_ids.ids)[0]
}

output "security_group_id" {
  value = aws_security_group.redshift_lambda_security_group.id
}