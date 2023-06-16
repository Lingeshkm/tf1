terraform {
  backend "s3" {
    bucket  = "terraform.staging-bc.intelerad.com"
    key     = "bc-staging/base-infra"
    region  = "ca-central-1"
    profile = "bc-staging"
  }
}

