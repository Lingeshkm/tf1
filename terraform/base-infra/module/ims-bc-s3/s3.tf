resource "aws_s3_bucket" "bc-bucket-res" {
  bucket = var.bucket_name
  acl = var.bucket_acl_type
  versioning {
    enabled = var.versioning
  }

  tags = {
    Name = var.s3_tag_name
    Environment = var.s3_tag_environment
    Owner = var.s3_tag_owner
  }
  policy = var.policy
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "bc-bucket-policy-res" {
  bucket = var.bucket_name
  depends_on = [aws_s3_bucket.bc-bucket-res]

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}
