terraform {
  backend "s3" {
    bucket  = "terraform.bc.intelerad.com"
    key     = "cognito/prod"
    region  = "ca-central-1"
    profile = "bc-prod"
  }
}

