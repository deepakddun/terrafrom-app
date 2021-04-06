provider "aws" {
  region = "us-east-2"
}

terraform {
  required_version = "> 0.12"

}

//Terraform 0.11 and earlier required all non-constant expressions to be
//provided via interpolation syntax, but this pattern is now deprecated. To
//silence this warning, remove the "${ sequence from the start and the }"
//sequence from the end of this expression, leaving just the inner expression.
//
//Template interpolation syntax is still used to construct strings from
//expressions when the template includes multiple interpolation sequences or a
//mixture of literal strings and interpolations. This deprecation applies only
//to templates that consist entirely of a single interpolation sequence.


// Adding the remote and removing local state config
/*
data "terraform_remote_state" "aws_iam_role" {
  backend = "local"

  config=  {
    path = "${path.module}/../aws_iam_role/terraform.tfstate"
  }
}

data "terraform_remote_state" "aws_vpc" {
  backend = "local"

  config = {
    path = "${path.module}/../aws_custom_vpc/terraform.tfstate"
  }
}
*/

data "terraform_remote_state" "aws_iam_role" {
  backend = "s3"

  config = {
    bucket = "nyeisterraformstatedata2"
    key = "iamrole/s3/terraform.tfstate"
    region = "us-east-2"
  }
}

data "terraform_remote_state" "aws_vpc" {

  backend = "s3"

  config = {
      bucket = "nyeisterraformstatedata2"
      key = "vpc/s3/terraform.tfstate"
      region = "us-east-2"

  }
}

resource "aws_redshift_cluster" "cluster_redshift_cluster" {
  cluster_identifier = "qa-redshift-cluster"
  node_type = "dc2.large"
  database_name = "qawarehouse"
  cluster_type = "single-node"
  port = "5439"
  master_username = "deepak"
  master_password = <password-here>
  #iam_roles = ["arn:aws:iam::427128480243:role/my_custom_redshift_role"]
  iam_roles = [data.terraform_remote_state.aws_iam_role.outputs.iam_role_arn]
  #cluster_security_groups = [aws_security_group.my_security_group.arn]
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  cluster_subnet_group_name = data.terraform_remote_state.aws_vpc.outputs.redshift_subnet_group_output
  publicly_accessible = "false"
  depends_on = [aws_security_group.my_security_group]
  final_snapshot_identifier = "false"
  skip_final_snapshot = "true"
}

resource "aws_security_group" "my_security_group" {
  name = "redshift_security_group"
  description = "The security group for redshift"
  vpc_id = data.terraform_remote_state.aws_vpc.outputs.vpc_id
  ingress {
    from_port = 5439
    protocol = "tcp"
    to_port = 5439
    cidr_blocks = ["24.29.75.132/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
  Name ="Redshift_Security_Group"
  }

}

terraform {
  backend "s3" {
   bucket = "nyeisterraformstatedata2"
    key = "redshift/s3/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform-up-and-running-locks-2"
    encrypt = true
  }
}


output "database_url" {
  value = aws_redshift_cluster.cluster_redshift_cluster.endpoint
}

