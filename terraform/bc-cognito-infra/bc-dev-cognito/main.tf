locals {
  environment        = "dev"
  environment_prefix = "dev"
  environment_tag    = "Development"
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
  onelogin_metadata_url            = "https://app.onelogin.com/saml/metadata/23d42557-c642-4af0-9c4b-2cb94976fdfb"
}
