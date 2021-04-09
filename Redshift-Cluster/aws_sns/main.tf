provider "aws" {
  region = "us-east-2"
}

terraform {
  required_version = "> 0.12"

}

resource "aws_sns_topic" "sns_topic" {
  name = "terraform-redshift-sns-topic"

  tags = {
    Created = "Terraform" ,
    Purpose = "ForRedshiftNotification"
  }
}

# lambda function for subscription to SNS queue

data "aws_lambda_function" "existing" {
  function_name = var.function_name
}

resource "aws_sns_topic_subscription" "sns_lambda_subscription" {
  endpoint = data.aws_lambda_function.existing.arn
  protocol = "lambda"
  topic_arn = aws_sns_topic.sns_topic.arn
}

# Terraform backend configuration
terraform {
  backend "s3" {
   bucket = "nyeisterraformstatedata2"
    key = "sns/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform-up-and-running-locks-2"
    encrypt = true
  }
}