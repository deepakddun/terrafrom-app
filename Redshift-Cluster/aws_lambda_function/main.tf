provider "aws" {
  region = "us-east-2"
}

resource "aws_iam_policy" "lambda_execution_policy" {
  name = "lambda_execution_policy"
  description = "the policy for putting lambda policy logs in cloudwatch"
  tags ={
    CreatedBy = "Terraform",
    For = "LambdaPolicy"
  }
  policy = jsonencode(
  {
  Version: "2012-10-17",
  Statement: [
    {
      Action: [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Resource: "arn:aws:logs:*:*:*",
      Effect: "Allow"
    },
    {
      Action: [
        "ec2:DescribeNetworkInterfaces",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeInstances",
        "ec2:AttachNetworkInterface"
      ],
      Resource: "*",
      Effect: "Allow"
    }
  ]
}
)
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"
  description = "the role for the lambda execution"
  tags = {
    CreatedBy = "Terraform",
    For = "LambdaRole"
  }
  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
        {
            Effect: "Allow",
            Principal: {
                "Service":"lambda.amazonaws.com"
            },
            Action: "sts:AssumeRole"
        }
    ]
})
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
  role = aws_iam_role.lambda_execution_role.name
  depends_on = [aws_iam_policy.lambda_execution_policy , aws_iam_role.lambda_execution_role]
}

resource "aws_lambda_function" "terraform_lambda_function" {
  function_name = "terraform-first-lambda-function"
  filename = "${path.module}/src.zip"
  handler = "first_function.hello"
  role = aws_iam_role.lambda_execution_role.arn
  runtime = "python3.8"
  source_code_hash = filebase64sha256("${path.module}/src.zip")

  tags = {
    CreatedBy="Terraform",
    For="LambdaExample"
  }

  vpc_config {
    security_group_ids =[aws_security_group.my_lambda_security_group.id]
    subnet_ids = [data.terraform_remote_state.aws_vpc.outputs.private_subnet_id , data.terraform_remote_state.aws_vpc.outputs.public_subnet_id]
  }

  depends_on = [aws_iam_role_policy_attachment.role_policy_attachment]
}

resource "aws_security_group" "my_lambda_security_group" {
  name = "lambda_security_group"
  description = "The security group for lambda"
  vpc_id = data.terraform_remote_state.aws_vpc.outputs.vpc_id
  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
  Name ="Terraform_Lambda_Security_Group"
  }

}

# Terraform custom vpc
data "terraform_remote_state" "aws_vpc" {

  backend = "s3"

  config = {
      bucket = "nyeisterraformstatedata2"
      key = "vpc/s3/terraform.tfstate"
      region = "us-east-2"

  }
}

# Terraform backend configuration
terraform {
  backend "s3" {
   bucket = "nyeisterraformstatedata2"
    key = "lambda/function/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform-up-and-running-locks-2"
    encrypt = true
  }
}