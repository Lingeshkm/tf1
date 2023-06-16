# For the S3 bucket we're creating here, we need to give Staging, Dev,
# read permission to this bucket.
#
module "ims-bc-s3" {
  source = "../base-infra/module/ims-bc-s3"

  bucket_name     = "bc-deployment-packages"
  bucket_acl_type = "private"
  versioning = false
  s3_tag_name = "bc-${local.environment}-codebuild-cache"
  s3_tag_owner = local.owner_tag
  s3_tag_environment     = local.environment
  policy          = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Terraform deployment",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::792686863424:role/cross_account_build_control_jenkins",
                    "arn:aws:iam::792686863424:role/cross_account_build_control_staging",
                    "arn:aws:iam::429656490274:role/cross_account_build_control_dev_jenkins",
                    "arn:aws:iam::429656490274:role/cross_account_build_control_dev",
                    "arn:aws:iam::414952023392:role/bc-prod-codebuild-role",
                    "arn:aws:iam::792686863424:role/bc-staging-codebuild-role",
                    "arn:aws:iam::429656490274:role/bc-dev-codebuild-role"
                ]
            },
            "Action": [
                "s3:GetObject",
                "s3:GetBucketLocation",
                "s3:List*"
            ],
            "Resource": [
              "arn:aws:s3:::bc-deployment-packages",
              "arn:aws:s3:::bc-deployment-packages/*"
            ]
        }
    ]
}
POLICY

}

module "ims-bc-s3-cache" {
  source = "../base-infra/module/ims-bc-s3"

  bucket_name     = "bc-${local.environment}-codebuild-cache"
  bucket_acl_type = "private"
  versioning = false
  s3_tag_name = "bc-${local.environment}-codebuild-cache"
  s3_tag_owner = local.owner_tag
  s3_tag_environment     = local.environment
  policy          = ""
}

module "ims-bc-codebuild" {
  source = "../base-infra/module/ims-bc-codebuild"

  codebuild_role                     = "bc-${local.environment}-codebuild-role"
  codebuild_project_description      = "CodeBuild for BuildInfo Services"
  codebuild_build_timeout            = "60"
  codebuild_package_bucket           = "bc-deployment-packages"
  codebuild_package_bucket_arn       = module.ims-bc-s3.bucket_arn
  codebuild_package_bucket_cache     = module.ims-bc-s3-cache.bucket_name
  codebuild_package_bucket_cache_arn = module.ims-bc-s3-cache.bucket_arn
  codebuild_package_filename         = "codebuild.zip"
  environment                        = local.environment
}

# This role is only present in PROD as it give access to PROD S3 bucket
# to Staging environment.
#
resource "aws_iam_role" "cross_account_s3_access_staging" {
  name = "bc_staging_can_read_prod_s3_role"

  assume_role_policy = <<POLICY
{
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Principal": {
                "AWS": "arn:aws:iam::429656490274:root"
            }
        }
    ],
    "Version": "2012-10-17"
}
POLICY

}

resource "aws_iam_role" "cross_account_s3_access_dev" {
  name = "bc_dev_can_read_prod_s3_role"

  assume_role_policy = <<POLICY
{
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Principal": {
                "AWS": "arn:aws:iam::429656490274:root"
            }
        }
    ],
    "Version": "2012-10-17"
}
POLICY

}

