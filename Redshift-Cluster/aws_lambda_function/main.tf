provider "aws" {
  region = "us-east-2"
}

data "aws_security_group" "redshift_security_group" {
    id = var.security_group_id
}

data "archive_file" "function_zip"{
  type = "zip"
  source_file = "${path.module}/first_function.py"
  output_path = "${path.module}/src.zip"
}

data "aws_sns_topic" "sns-topic" {
  name = var.sns_queue
}

resource "aws_iam_policy" "lambda_execution_policy" {
  name = "lambda_execution_policy_terraform"
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
    },
    {
      Action: [
        "redshift:Describe*",
        "redshift:Get*",
        "redshift:ViewQueriesInConsole",
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAddresses",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcs",
        "ec2:DescribeInternetGateways",
        "sns:Get*",
        "sns:List*",
        "cloudwatch:Describe*",
        "cloudwatch:List*",
        "cloudwatch:Get*"
      ],
      Resource: "*",
      Effect: "Allow"
    },
    {
      Action: [
         "redshift-data:ExecuteStatement",
         "redshift-data:CancelStatement",
         "redshift-data:ListStatements",
         "redshift-data:GetStatementResult",
         "redshift-data:DescribeStatement",
         "redshift-data:ListDatabases",
         "redshift-data:ListSchemas",
         "redshift-data:ListTables",
         "redshift-data:DescribeTable"
         ],
         Effect: "Allow",
         Resource: "*"
    }
  ]
}
)
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role_terraform"
  description = "the role for the lambda execution by terraform"
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
  function_name = "terraform-second-lambda-function"
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
    security_group_ids =[data.aws_security_group.redshift_security_group.id]
    subnet_ids = [data.terraform_remote_state.aws_vpc.outputs.private_subnet_id]
  }

  depends_on = [aws_iam_role_policy_attachment.role_policy_attachment , data.archive_file.function_zip]
}

resource "aws_lambda_permission" "lambda_with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.terraform_lambda_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = data.aws_sns_topic.sns-topic.arn
}

//resource "aws_security_group" "my_lambda_security_group" {
//  name = "lambda_security_group"
//  description = "The security group for lambda"
//  vpc_id = data.terraform_remote_state.aws_vpc.outputs.vpc_id
//  ingress {
//    from_port = 0
//    protocol = "-1"
//    to_port = 0
//    cidr_blocks = ["0.0.0.0/0"]
//  }
//
//  egress {
//    from_port   = 0
//    to_port     = 0
//    protocol    = "-1"
//    cidr_blocks = ["0.0.0.0/0"]
//  }
//
//  tags = {
//  Name ="Terraform_Lambda_Security_Group"
//  }
//
//}

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