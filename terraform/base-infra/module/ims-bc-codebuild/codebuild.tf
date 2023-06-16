terraform {
  required_version = "> 0.12"
}

resource "aws_iam_role" "codebuild_role" {
  name = var.codebuild_role

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "codebuild_policy"
  role = aws_iam_role.codebuild_role.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:List*"
      ],
      "Resource": [
        "${var.codebuild_package_bucket_arn}",
        "${var.codebuild_package_bucket_arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetBucketLocation",
        "s3:List*"
      ],
      "Resource": [
        "${var.codebuild_package_bucket_cache_arn}",
        "${var.codebuild_package_bucket_cache_arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "codebuild_project" {
  name          = var.codebuild_project_name
  description   = var.codebuild_project_description
  build_timeout = var.codebuild_build_timeout
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
    location = var.codebuild_package_bucket_cache
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
  }

  source {
    type            = "S3"
    location        = "${var.codebuild_package_bucket}/${var.codebuild_package_filename}"
  }

  tags = {
    "Environment" = var.environment
  }
}
