provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "bucket" {

  bucket = "nice-uat-data-warehouse"

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
    Purpose = "userdataset",
    creator = "deepak-terraform"
  }

}


resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.bucket.bucket
  #key = "${path.module}/caseheader/sample.txt"
  #source = "${path.module}/sample.txt"

  for_each = fileset("/home/deepak/developer_survey_2020", "*")

  key = "data-2020/${each.value}"

  source = "/home/deepak/developer_survey_2020/${each.value}"

  depends_on = [aws_s3_bucket.bucket]
}

resource "aws_s3_bucket_public_access_block" "data-2020" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls   = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true


}

terraform {
  backend "s3" {
   bucket = "nyeisterraformstatedata2"
    key = "data-source/s3/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform-up-and-running-locks-2"
    encrypt = true
  }
}

output "sample" {
  value = aws_s3_bucket.bucket.bucket_domain_name
}
