terraform {
  backend "s3" {
    bucket  = "terraform.dev-bc.intelerad.com"
    key     = "cognito/dev"
    region  = "ca-central-1"
    profile = "bc-dev"
  }
}

