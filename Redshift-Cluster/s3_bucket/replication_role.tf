provider "aws" {
  region = "us-east-2"
}

terraform {
  required_version = "> 0.12.0"
}

locals {
  source_bucket = aws_s3_bucket.uat_test_bucket_source.arn
  destination_bucket = aws_s3_bucket.uat_test_bucket_destination.arn

}

resource "aws_iam_policy" "s3_policy_replication_terraform" {
  name = "s3_replication_policy"
  description = "the policy to be attached to iam role for replication"
  policy = jsonencode({
    Version: "2012-10-17",
    "Statement": [
      {
        Action: [
          "s3:ListBucket",
          "s3:GetReplicationConfiguration",
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging",
          "s3:GetObjectRetention",
          "s3:GetObjectLegalHold"
        ],
        Effect: "Allow",
        Resource: [
          "${local.source_bucket}",
          "${local.source_bucket}/*",
          "${local.destination_bucket}",
          "${local.destination_bucket}/*"
        ]
      },
      {
        Action: [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags",
          "s3:ObjectOwnerOverrideToBucketOwner"
        ],
        Effect: "Allow",
        Resource: [
          "${local.source_bucket}/*",
          "${local.destination_bucket}/*",
        ]
      }
    ]
  }
  )
}

resource "aws_iam_role" "my_cutsomizable_redift_role_for_replication" {
  name = "my_custom_s3_replication_role"
  #depends_on = [aws_iam_policy.s3_policy_replication_terraform]
  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
        {
            Effect: "Allow",
            Principal: {
                "Service":"s3.amazonaws.com"
            },
            Action: "sts:AssumeRole"
        }
    ]
})

}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  policy_arn =aws_iam_policy.s3_policy_replication_terraform.arn
  role = aws_iam_role.my_cutsomizable_redift_role_for_replication.name
  #depends_on = [aws_iam_role.my_cutsomizable_redift_role_for_replication]
}

terraform {
  backend "s3" {
   bucket = "nyeisterraformstatedata2"
    key = "global/s3/replication/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform-up-and-running-locks-2"
    encrypt = true
  }
}
