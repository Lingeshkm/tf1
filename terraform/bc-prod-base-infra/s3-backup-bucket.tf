resource "aws_s3_bucket" "s3_bc_backup" {
  bucket = "ims-bc-backup-prod"
  acl    = "private"
  policy = <<BUCKETPOLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "dev staging access",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::429656490274:role/cross_account_build_control_dev",
                    "arn:aws:iam::792686863424:role/cross_account_build_control_staging",
                    "arn:aws:iam::429656490274:role/cross_account_build_control_dev_jenkins",
                    "arn:aws:iam::792686863424:role/cross_account_build_control_jenkins",
                    "arn:aws:iam::429656490274:role/SonarQubeEC2Role"
                ]
            },
            "Action": [
                "s3:GetObject",
                "s3:GetBucketLocation",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::ims-bc-backup-prod",
                "arn:aws:s3:::ims-bc-backup-prod/*"
            ]
        }
    ]
}
BUCKETPOLICY


  tags = {
    Name        = "IMS BC Backup"
    Terraform   = "True"
    Environment = "Prod"
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id                                     = "ShortTerm ExpirationRule"
    enabled                                = true

    tags = {
      "KeepArchive" = "ShortTerm"
    }

    expiration {
      days = 3
    }

    noncurrent_version_expiration {
      days = 3
    }
  }

  lifecycle_rule {
    id                                     = "DeepArchiveGlacier ExpirationRule"
    enabled                                = true

    tags = {
        "KeepArchive" = "DeepArchiveGlacier"
      }

    transition {
      days = 7
      storage_class = "DEEP_ARCHIVE"
    }

    expiration {
      days = 180
    }

    noncurrent_version_expiration {
      days = 3
    }
  }

}

resource "aws_s3_bucket_public_access_block" "bc-backup" {
  bucket = aws_s3_bucket.s3_bc_backup.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


