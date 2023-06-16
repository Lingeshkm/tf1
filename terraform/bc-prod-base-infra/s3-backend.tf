terraform {
  backend "s3" {
    bucket  = "terraform.bc.intelerad.com"
    key     = "bc-prod/base-infra"
    region  = "ca-central-1"
    profile = "bc-prod"
  }
}

