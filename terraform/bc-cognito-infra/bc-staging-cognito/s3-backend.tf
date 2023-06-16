terraform {
  backend "s3" {
    bucket  = "terraform.staging-bc.intelerad.com"
    key     = "cognito/staging"
    region  = "ca-central-1"
    profile = "bc-staging"
  }
}

