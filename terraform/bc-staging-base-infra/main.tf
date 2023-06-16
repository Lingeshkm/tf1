locals {
  environment                 = "staging"
  environment_prefix          = "staging"
  environment_tag             = "Staging"
  owner_tag                   = "BC"
  pg_buildinfo_read_username  = "buildinfo_read"
  pg_buildinfo_write_username = "buildinfo_write"
  production_account_number   = "414952023392"
  bc_domain                   = "${local.environment_prefix}-bc.intelerad.com"
  rnd_ci_ip                   = "10.90.129.74"  // rnd-testci
  infrabuild_ip               = "10.90.152.53"  // infrabuild.intelerad.com
  rnd_artifacts_ip            = "10.90.129.55"  // rnd-testartifacts.intelerad.com
}

provider "aws" {
  version = "~> 2.70.0"
  region  = "us-east-2"
  profile = "bc-staging"
}

provider "aws" {
  version = "~> 2.70.0"
  region  = "us-east-1"
  profile = "bc-${local.environment}"
  alias   = "us-east-1"
}

######
# Data
######

data "aws_route53_zone" "route53_zone_id" {
  name = "${local.bc_domain}."
}

data "aws_acm_certificate" "bc_aws_cert" {
  domain   = "*.${local.bc_domain}"
  statuses = ["ISSUED"]
}

data "aws_elb_service_account" "main" {
}

data "aws_ami" "sonar_ami" {
  owners      = [local.production_account_number]
  most_recent = true

  filter {
    name   = "name"
    values = ["ims-bc-sonarqube_*"]
  }
}

data "aws_ami" "jenkins_ami" {
  owners      = [local.production_account_number]
  most_recent = true

  filter {
    name   = "name"
    values = ["ims-bc-generic-jenkins-slave_*"]
  }
}




module "ims-bc-base-infra" {
  source                = "../base-infra/module/ims-bc-base-infra"
  vpc_environment       = local.environment
  vpc_tag               = local.environment_prefix
  vpc_subnets_app_2a    = "10.60.193.0/24"
  vpc_subnets_app_2b    = "10.60.194.0/24"
  vpc_subnets_lambda_2c = "10.60.195.0/24"
  vpc_subnets_lambda_2b = "10.60.196.0/24"
  vpc_subnets_rds_2a    = "10.60.197.0/26"
  vpc_subnets_rds_2b    = "10.60.197.64/26"
  vpc_subnets_elb_2a    = "10.60.197.128/26"
  vpc_subnets_elb_2b    = "10.60.197.192/26"
  vpc_subnets_build_2a  = "10.60.198.0/24"
  vpc_subnets_build_2b  = "10.60.199.0/24"
  vpc_subnets_endpoints_2a  = "10.60.200.0/26"
  vpc_subnets_endpoints_2b  = "10.60.200.64/26"
}

######
# S3
######

resource "aws_s3_bucket" "ims-bc-env-logs" {
  bucket = "ims-bc-${local.environment}-logs"
  acl    = "private"
  policy = <<BUCKETPOLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "s3 bucket for logs",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${data.aws_elb_service_account.main.arn}"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::ims-bc-${local.environment_prefix}-logs/alb-${local.environment_prefix}/AWSLogs/${module.ims-bc-base-infra.account_id}/*"
        },
        {
            "Sid": "AWSLogDeliveryWrite",
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::ims-bc-${local.environment_prefix}-logs/AWSLogs/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            "Sid": "AWSLogDeliveryAclCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::ims-bc-${local.environment_prefix}-logs"
        }
    ]
}
BUCKETPOLICY


  tags = {
    Name        = "Application logs bucket"
    Owner       = local.owner_tag
    Environment = local.environment_tag
  }

  versioning {
    enabled = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id                                     = "ExpiryAfter15days"
    enabled                                = true
    abort_incomplete_multipart_upload_days = 5

    expiration {
      days = 15
    }

    noncurrent_version_expiration {
      days = 15
    }
  }
}

resource "aws_s3_bucket_public_access_block" "ims-bc-env-logs-public-bucket-access" {
  bucket = aws_s3_bucket.ims-bc-env-logs.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "ims-bc-releases-s3" {
  source      = "../base-infra/module/ims-bc-releases-s3"
  bucket_name = "ims-bc-releases-${local.environment_prefix}"
  bucket_acl_type = "private"
  versioning  = true
  s3_tag_name= "ims-bc-releases"
  s3_tag_owner = local.owner_tag
  s3_tag_environment = local.environment_prefix
  policy = ""
}

#########
# Route53
#########

module "ims-bc-route53" {
  source             = "../base-infra/module/ims-bc-route53"
  zone_id            = data.aws_route53_zone.route53_zone_id.id
  bitbucket_ip_addr  = "10.90.129.44"
  confluence_ip_addr = "10.90.129.44"
}


####
# AMI Sharing
####
module "ims-bc-amibuild-grant" {
  source      = "../base-infra/module/ims-bc-amibuild-grant"
  environment = local.environment
  key_arn     = "arn:aws:kms:us-east-2:414952023392:key/9cf4e136-c03a-43e8-957d-708ebe9a739a"
}

module "ims-bc-dashboard" {
  source = "../base-infra/module/ims-bc-cloudwatch-dashboard"
}

module "ims-bc-s3-account" {
  source = "../base-infra/module/ims-bc-s3-account"
}

module "ims-bc-cloudfront-cert" {
  source = "../base-infra/module/ims-bc-cloudfront-cert"
  zone_id = data.aws_route53_zone.route53_zone_id.zone_id
  domain_name = local.bc_domain

  providers = {
    aws.us-east-1 = aws.us-east-1
  }
}
