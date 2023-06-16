resource "aws_s3_bucket" "ims-bc-release-s3" {
  bucket = var.bucket_name
  acl = var.bucket_acl_type
  versioning {
    enabled = var.versioning
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*.intelerad.com"]
    expose_headers  = ["x-amz-server-side-encryption", "x-amz-request-id", "x-amz-id-2", "ETag"]
    max_age_seconds = 3000
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

  // Delete files older than 30 days old within /tmp/ folder
  lifecycle_rule {
    id      = "tmp"
    prefix  = "tmp/"
    enabled = true

    expiration {
      days = 30
    }
  }
}

resource "aws_s3_bucket_public_access_block" "ims-bc-release-bucket-policy-res" {
  bucket = var.bucket_name
  depends_on = [aws_s3_bucket.ims-bc-release-s3]

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}
