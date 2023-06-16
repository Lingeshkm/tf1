data "aws_s3_bucket" "bc-prod-deploy-bucket" {
  bucket = "bc-deployment-packages"
}

module "ims-bc-s3-cache" {
  source = "../base-infra/module/ims-bc-s3"

  bucket_name     = "bc-staging-codebuild-cache"
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
  codebuild_package_bucket           = data.aws_s3_bucket.bc-prod-deploy-bucket.bucket
  codebuild_package_bucket_arn       = data.aws_s3_bucket.bc-prod-deploy-bucket.arn
  codebuild_package_bucket_cache     = module.ims-bc-s3-cache.bucket_name
  codebuild_package_bucket_cache_arn = module.ims-bc-s3-cache.bucket_arn
  codebuild_package_filename         = "codebuild.zip"
  environment                        = "staging"
}

