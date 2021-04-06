provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "bucket" {

  bucket = "nyeisterraformstatedata2"

  acl = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = "true"
  }

  tags = {
    Purpose = "terraformstatebucket",
    creator = "terraform"
  }

}


/*resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.bucket.bucket
  #key = "${path.module}/caseheader/sample.txt"
  #source = "${path.module}/sample.txt"

  for_each = fileset("/home/deepak/developer_survey_2019", "*")

  key = "data-2019/${each.value}"

  source = "/home/deepak/developer_survey_2019/${each.value}"

  depends_on = [aws_s3_bucket.bucket]
}*/

resource "aws_s3_bucket_public_access_block" "data-2019" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls   = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true


}

resource "aws_dynamodb_table" "terraform_locks" {
  hash_key = "LockID"
  name = "terraform-up-and-running-locks-2"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
   bucket = "nyeisterraformstatedata2"
    key = "global/s3/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform-up-and-running-locks-2"
    encrypt = true
  }
}


output "sample" {
  value = aws_s3_bucket.bucket.bucket_domain_name
}

output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}
