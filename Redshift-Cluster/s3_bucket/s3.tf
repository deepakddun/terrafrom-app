

resource "aws_s3_bucket" "uat_test_bucket_source" {

  bucket = "uat-data-demographics-nice-source"

  acl = "private"

  versioning {
    enabled = "true"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  replication_configuration {
    role = aws_iam_role.my_cutsomizable_redift_role_for_replication.arn
    rules {
      status = "Enabled"
      id = "replication1"
      destination {
        bucket = aws_s3_bucket.uat_test_bucket_destination.arn
       access_control_translation {
         owner = "true"
       } 

      }
    }
  }

  tags = {
    Type = "Nice-Source-Bucket",
    Environment = "UAT"
  }
 }

resource "aws_s3_bucket" "uat_test_bucket_destination" {

  bucket = "uat-data-demographics-pc-nice-destination"

  acl = "private"

  versioning {
    enabled = "true"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Type = "Nice-Dest-Bucket",
    Environment = "UAT"
  }
 }