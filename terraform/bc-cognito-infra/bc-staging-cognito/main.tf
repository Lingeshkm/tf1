locals {
  environment        = "staging"
  environment_prefix = "staging"
  environment_tag    = "Staging"
  owner_tag          = "BC"
}

provider "aws" {
  region  = "us-east-2"
  profile = "bc-${local.environment}"
}

module "ims-bc-cognito" {
  source                           = "../base-infra/"
  environment                      = local.environment
  user_pool_domain                 = "ims-bc-login-${local.environment}"
  onelogin_metadata_url            = "https://app.onelogin.com/saml/metadata/8234492a-e729-4b45-b5ec-6d0451a211ab"
}

