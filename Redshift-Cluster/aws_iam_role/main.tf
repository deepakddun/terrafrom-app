provider "aws" {
  region = "us-east-2"
}

terraform {
  required_version = "> 0.12.0"
}

resource "aws_iam_policy" "s3_policy_terraform" {
  name = "s3_terraform_policy"
  description = "the policy to be attached to iam role"
  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
            Effect: "Allow",
            Action: [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket"
            ],
            Resource: [
                "arn:aws:s3:::nice-uat-data-warehouse",
                "arn:aws:s3:::nice-uat-data-warehouse/*"
            ]
        }
    ]
})
}



resource "aws_iam_role" "my_cutsomizable_redift_role" {
  name = "my_custom_redshift_role"
  depends_on = [aws_iam_policy.s3_policy_terraform]
  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
        {
            Effect: "Allow",
            Principal: {
                "Service":"redshift.amazonaws.com"
            },
            Action: "sts:AssumeRole"
        }
    ]
})
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  policy_arn = aws_iam_policy.s3_policy_terraform.arn
  role = aws_iam_role.my_cutsomizable_redift_role.name
  depends_on = [aws_iam_policy.s3_policy_terraform , aws_iam_role.my_cutsomizable_redift_role]
}

terraform {
  backend "s3" {
   bucket = "nyeisterraformstatedata2"
    key = "iamrole/s3/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform-up-and-running-locks-2"
    encrypt = true
  }
}

output "iam_policy_name" {
  value = aws_iam_role.my_cutsomizable_redift_role.id
}

output "iam_policy_arn" {
  value = aws_iam_policy.s3_policy_terraform.arn
}

output "iam_role_arn" {
  value = aws_iam_role.my_cutsomizable_redift_role.arn
}



