output "user_pool_id" {
  value = aws_cognito_user_pool.user_pool.id
}

output "user_pool_arn" {
  value = aws_cognito_user_pool.user_pool.arn
}

output "cognito_saml_provider_name" {
  value = aws_cognito_identity_provider.onelogin_saml_provider.provider_name
}
