terraform {
  backend "s3" {
    bucket  = "terraform.dev-bc.intelerad.com"
    key     = "bc-dev/base-infra"
    region  = "ca-central-1"
    profile = "bc-dev"
  }
}

