variable "codebuild_role" {
  description = "Security rule used by CodeBuild"
  type        = string
}

variable "codebuild_project_name" {
  description = "CodeBuild Project Name"
  default     = "bc-serverless-deploy"
  type        = string
}

variable "codebuild_project_description" {
  description = "CodeBuild Project description"
  type        = string
}

variable "codebuild_build_timeout" {
  description = "CodeBuild Build Timeout"
  type        = string
}

variable "codebuild_package_bucket" {
  description = "CodeBuild package S3 bucket name"
  type        = string
}

variable "codebuild_package_bucket_arn" {
  description = "CodeBuild package S3 bucket ARN"
  type        = string
}

variable "codebuild_package_bucket_cache" {
  description = "CodeBuild package S3 bucket name for the Cache"
  type        = string
}

variable "codebuild_package_bucket_cache_arn" {
  description = "CodeBuild package S3 bucket ARN for the Cache"
  type        = string
}

variable "codebuild_package_filename" {
  description = "CodeBuild package filename (zip file)"
  type        = string
  default     = "codebuild.zip"
}

variable "environment" {
  description = "Environment tag name"
  type        = string
}
