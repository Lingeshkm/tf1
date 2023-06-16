variable "environment" {
  description = "Which environment the VPC is running in"
  type        = string
  default = ""
}

variable "user_pool_domain" {
  description = "Domain name for cognito sign in page"
  type = string
}

variable "onelogin_metadata_url" {
  description = "The https link for the OneLogin metadata document"
  type = string
}
