data "aws_region" "current" {}

data "aws_caller_identity" "my_identity" {}

resource "aws_cognito_user_pool" "user_pool" {
  name = "ims_user_pool"
  username_attributes = ["email"]
  auto_verified_attributes = ["email"]

  mfa_configuration = "OFF"
  password_policy {
    minimum_length    = 8
    require_lowercase = false
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
    temporary_password_validity_days = 7
  }
  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true

    string_attribute_constraints {
      min_length = 1
      max_length = 2048
    }
  }

  tags = {
    Name = "BC cognito user pool"
    Environment = var.environment
    Owner = "BC"
  }
}

resource "aws_cognito_user_pool_domain" "pool_domain" {
  user_pool_id = aws_cognito_user_pool.user_pool.id
  domain = var.user_pool_domain
}

resource "aws_cognito_identity_provider" "onelogin_saml_provider" {
  user_pool_id = aws_cognito_user_pool.user_pool.id
  provider_name = "OneLoginIms"
  provider_type = "SAML"

  provider_details = {
    MetadataURL = var.onelogin_metadata_url
    SLORedirectBindingURI = "ignored"    # see ignore_changes below
    SSORedirectBindingURI = "ignored"    # see ignore_changes below
  }

  attribute_mapping = {
    email = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"
    given_name = "first_name"
    family_name = "last_name"
    preferred_username = "ad_username"
  }

  lifecycle {
    ignore_changes = [
      provider_details["SLORedirectBindingURI"],
      provider_details["SSORedirectBindingURI"]
    ]
  }
}

#####
# SSM
#####
resource "aws_ssm_parameter" "cognito_user_pool_id" {
  name = "/base_infra/${var.environment}/cognito_user_pool_id"
  type = "String"
  description = " The user pool id of the cognito pool"
  value = aws_cognito_user_pool.user_pool.id
  tags = {
    Environment = var.environment
    Owner = "BC"
    Compliance = "NONE"
  }
}

resource "aws_ssm_parameter" "cognito_user_pool_name" {
  name = "/base_infra/${var.environment}/cognito_user_pool_name"
  type = "String"
  description = "The name of the cognito pool"
  value = aws_cognito_user_pool.user_pool.name
  tags = {
    Environment = var.environment
    Owner = "BC"
    Compliance = "NONE"
  }
}

resource "aws_ssm_parameter" "cognito_user_pool_arn" {
  name = "/base_infra/${var.environment}/cognito_user_pool_arn"
  type = "String"
  description = "The arn of the cognito pool"
  value = aws_cognito_user_pool.user_pool.arn
  tags = {
    Environment = var.environment
    Owner = "BC"
    Compliance = "NONE"
  }
}
