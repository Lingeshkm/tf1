locals {
  environment        = "prod"
  environment_prefix = "prod"
  environment_tag    = "Production"
  owner_tag          = "BC"
}

provider "aws" {
  region  = "us-east-2"
  profile = "bc-${local.environment}"
}

module "ims-bc-cognito" {
  source                           = "../base-infra/"
  environment                      = local.environment
  user_pool_domain                 = "ims-bc-login"
  onelogin_metadata_url            = "https://app.onelogin.com/saml/metadata/7b182d69-182d-4418-84cc-fac1b4e219ef"
}

