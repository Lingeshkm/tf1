# The CloudFront certificates need to come from us-east-1
provider "aws" {
  alias = "us-east-1"
}

resource "aws_acm_certificate" "cert" {
  provider          = aws.us-east-1

  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"
  tags              = var.common_tags
}

# Technically we don't need to perform the validation as the CNAME records already exist
# from the cloud infra acm certificate within us-east-2. It seems to generate the same verification
# when we generate the same wildcard within us-east-1.
//locals {
//  resource_record_name  = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name
//  resource_record_type  = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_type
//  resource_record_value = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_value
//}
//
//resource "aws_route53_record" "cert_validation" {
//  provider = aws.us-east-1
//  name     = local.resource_record_name
//  type     = local.resource_record_type
//  zone_id  = var.zone_id
//  records  = [local.resource_record_value]
//  ttl      = 60
//}
//
//resource "aws_acm_certificate_validation" "cert" {
//  provider                = aws.us-east-1
//  certificate_arn         = aws_acm_certificate.cert.arn
//  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
//}
