variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "bucket_acl_type" {
  description = "S3 bucket acl type (private/public)"
  type        = string
  default     = "private"
}

variable "policy" {
  description = "IAM policy for the bucket"
  type        = string
  default     = ""
}

variable "versioning" {
  description = " Enable file version"
  type = bool
}

variable "s3_tag_environment" {
  description = "Environment tag name"
  type        = string
}

variable "s3_tag_name" {
  description = "name tag name"
  type        = string
}

variable "s3_tag_owner" {
  description = "Owner tag name"
  type        = string
}
