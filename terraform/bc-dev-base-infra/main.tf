locals {
  environment                 = "dev"
  environment_prefix          = "dev"
  environment_tag             = "Development"
  owner_tag                   = "BC"
  pg_buildinfo_read_username  = "buildinfo_read"
  pg_buildinfo_write_username = "buildinfo_write"
  bc_domain                   = "${local.environment_prefix}-bc.intelerad.com"
  production_account_number   = "414952023392"
  rnd_ci_ip                   = "10.90.129.74"  // rnd-testci
  infrabuild_ip               = "10.90.152.53"  // infrabuild.intelerad.com
  rnd_artifacts_ip            = "10.90.129.55"  // rnd-testartifacts.intelerad.com
}

provider "aws" {
  version = "~> 2.70.0"
  region  = "us-east-2"
  profile = "bc-${local.environment}"
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
  vpc_tag               = local.environment
  vpc_subnets_app_2a    = "10.60.129.0/24"
  vpc_subnets_app_2b    = "10.60.130.0/24"
  vpc_subnets_lambda_2c = "10.60.131.0/24"
  vpc_subnets_lambda_2b = "10.60.132.0/24"
  vpc_subnets_rds_2a    = "10.60.133.0/26"
  vpc_subnets_rds_2b    = "10.60.133.64/26"
  vpc_subnets_elb_2a    = "10.60.133.128/26"
  vpc_subnets_elb_2b    = "10.60.133.192/26"
  vpc_subnets_build_2a  = "10.60.134.0/24"
  vpc_subnets_build_2b  = "10.60.135.0/24"
  vpc_subnets_endpoints_2a  = "10.60.136.0/26"
  vpc_subnets_endpoints_2b  = "10.60.136.64/26"
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


#####
# ALB
#####

module "ims-bc-alb" {
  source                = "../base-infra/module/ims-bc-alb"
  load_balancer_name    = "alb-${local.environment_prefix}"
  alb_vpc_id            = module.ims-bc-base-infra.vpc_id
  alb_subnet_ids        = data.aws_subnet_ids.ssm_elb_subnets.ids
  s3_log_bucket_name    = aws_s3_bucket.ims-bc-env-logs.bucket
  s3_log_prefix_name    = "alb-${local.environment_prefix}"
  alb_name_tag          = "ALB"
  alb_owner             = local.owner_tag
  alb_environment       = local.environment_tag
  alb_certificate_arn   = data.aws_acm_certificate.bc_aws_cert.arn
  sonar_alb_forward_host      = ["sonar.${local.bc_domain}"]
  rnd_ci_alb_forward_host = ["rnd-ci.${local.bc_domain}"]
  rnd_ci_target_ip = "${local.rnd_ci_ip}"
  infrabuild_alb_forward_host = ["infrabuild.${local.bc_domain}"]
  infrabuild_target_ip = "${local.infrabuild_ip}"
  rnd_artifacts_alb_forward_host = ["rnd-artifacts.${local.bc_domain}"]
  rnd_artifacts_target_ip = "${local.rnd_artifacts_ip}"
}

#########
# Route53
#########

resource "aws_route53_record" "alb_sonarqube_alias" {
  name    = "sonar.${local.bc_domain}"
  type    = "A"
  zone_id = data.aws_route53_zone.route53_zone_id.id

  alias {
    name                   = module.ims-bc-alb.alb_dns_name
    zone_id                = module.ims-bc-alb.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "alb_rndci_alias" {
  name    = "rnd-ci.${local.bc_domain}"
  type    = "A"
  zone_id = data.aws_route53_zone.route53_zone_id.id

  alias {
    name                   = module.ims-bc-alb.alb_dns_name
    zone_id                = module.ims-bc-alb.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "alb_infrabuild_alias" {
  name    = "infrabuild.${local.bc_domain}"
  type    = "A"
  zone_id = data.aws_route53_zone.route53_zone_id.id

  alias {
    name                   = module.ims-bc-alb.alb_dns_name
    zone_id                = module.ims-bc-alb.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "alb_rnd_artifacts_alias" {
  name    = "rnd-artifacts.${local.bc_domain}"
  type    = "A"
  zone_id = data.aws_route53_zone.route53_zone_id.id

  alias {
    name                   = module.ims-bc-alb.alb_dns_name
    zone_id                = module.ims-bc-alb.alb_zone_id
    evaluate_target_health = true
  }
}

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

#####
# Sonar
#####

module "ims-bc-sonar" {
  source                           = "../base-infra/module/ims-bc-sonar"
  sonar_name                       = "sonar-${local.environment_prefix}"
  launch_conf_name                 = "sonar-${local.environment_prefix}-launch-configuration"
  ami_id                           = data.aws_ami.sonar_ami.id
  ec2_instance_type                = "t3a.medium"
  amibuild_service_linked_role_arn = module.ims-bc-amibuild-grant.arn

  sonar_efs_id = module.ims-bc-efs.efs_sonar_id
  sonar_sg = [
    module.ims-bc-alb.alb_client_sg_id,
    module.ims-bc-rds.rds_outbound_security_group_id,
    module.ims-bc-efs.efs_client_security_group_id,
    module.ims-bc-base-infra.all_outbound_sg_id,
  ]
  sonar_lb_id    = [module.ims-bc-alb.alb_target_group_arns]
  sonar_asg_name = "sonar-asg-${local.environment_prefix}"
  sonar_asg_subnets = [
    module.ims-bc-base-infra.vpc_subnets_app_2a_id,
    module.ims-bc-base-infra.vpc_subnets_app_2b_id,
  ]
  sonar_tag_name        = "sonarqube_asg"
  sonar_tag_environment = local.environment_prefix
  sonar_tag_owner       = local.owner_tag
}

####
# AWS Jenkins builder
####

module "ims-bc-jenkins-builder" {
  source                           = "../base-infra/module/ims-bc-jenkins-builder"
  jenkins_name                     = "jenkins-nodes-${local.environment_prefix}"
  ami_id                           = data.aws_ami.jenkins_ami.id
  ec2_instance_type                = "t3a.xlarge"
  ssh_key_name                     = "jenkins-ci-master"
  cpu_credits                      = "unlimited"
  instance_count                   = "0"
  ebs_optimized                    = "true"
  amibuild_service_linked_role_arn = module.ims-bc-amibuild-grant.arn

  vpc_security_group_ids = [
    module.ims-bc-alb.alb_client_sg_id,
    module.ims-bc-base-infra.jenkins-master_sg_id,
    module.ims-bc-base-infra.all_outbound_sg_id,
  ]
  subnet_ids = [
    module.ims-bc-base-infra.vpc_subnets_build_2a_id,
    module.ims-bc-base-infra.vpc_subnets_build_2b_id,
  ]
  jenkins_tag_name = "jenkins_builder"
  jenkins_tag_environment = local.environment_prefix
  jenkins_tag_owner       = local.owner_tag
}

module "secretsmanager" {
  source     = "../base-infra/module/ims-bc-secretsmanager"
  key_prefix = local.environment_prefix

  postgres_host = module.ims-bc-rds.rds_instance_address
}

module "ims-bc-efs" {
  source          = "../base-infra/module/ims-bc-efs"
  vpc_id          = data.aws_vpc.vpc_ssm.id
  efs_subnet_id_1 = module.ims-bc-base-infra.vpc_subnets_app_2a_id
  efs_subnet_id_2 = module.ims-bc-base-infra.vpc_subnets_app_2b_id
  environment     = local.environment
  environment_tag = local.environment_tag
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
