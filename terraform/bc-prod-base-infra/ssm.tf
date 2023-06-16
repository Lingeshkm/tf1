module "ssm" {
  source                         = "../base-infra/module/ims-bc-ssm-base-infra"
  key_prefix                     = local.environment_prefix
  vpc_id                         = data.aws_vpc.vpc_ssm.id
  subnet_app_2a                  = module.ims-bc-base-infra.vpc_subnets_app_2a_id
  subnet_app_2b                  = module.ims-bc-base-infra.vpc_subnets_app_2b_id
  lambda_subnet_2c               = module.ims-bc-base-infra.vpc_subnets_lambda_2c_id
  lambda_subnet_2b               = module.ims-bc-base-infra.vpc_subnets_lambda_2b_id
  rds_subnet_2a                  = module.ims-bc-base-infra.vpc_subnets_rds_2a_id
  rds_subnet_2b                  = module.ims-bc-base-infra.vpc_subnets_rds_2b_id
  elb_subnet_2a                  = module.ims-bc-base-infra.vpc_subnets_elb_2a_id
  elb_subnet_2b                  = module.ims-bc-base-infra.vpc_subnets_elb_2b_id
  pg_buildinfo_read_username     = local.pg_buildinfo_read_username
  pg_buildinfo_write_username    = local.pg_buildinfo_write_username
  rds_client_security_group      = module.ims-bc-rds.rds_outbound_security_group_id
  rnd_bcdb_fqdn                  = module.ims-bc-rds.rds_instance_address
  vpc_cidr_block                 = data.aws_vpc.vpc_ssm.cidr_block
  all_outbound_security_group    = module.ims-bc-base-infra.all_outbound_sg_id
  ev_latest_release_manifest_url = "https://buildrepo.intelerad.com/modules/intelerad-enhancedviewer/release/intelerad-enhancedviewer.manifest.xml"
  buildinfo_api                  = "https://buildinfo-api.${local.bc_domain}/"
}

resource "random_string" "random_rds_admin_pw" {
  length  = 16
  special = true
}

data "aws_vpc" "vpc_ssm" {
  filter {
    name = "tag:ims:environment"
    values = [local.environment_prefix]
  }
}

data "aws_subnet_ids" "ssm_app_subnets" {
  vpc_id = data.aws_vpc.vpc_ssm.id
  filter {
    name   = "tag:Label"
    values = ["Application_network"]
  }
}

data "aws_subnet_ids" "ssm_lambda_subnets" {
  vpc_id = data.aws_vpc.vpc_ssm.id
  filter {
    name   = "tag:Label"
    values = ["Lambda_network"]
  }
}

data "aws_subnet_ids" "ssm_rds_subnets" {
  vpc_id = data.aws_vpc.vpc_ssm.id
  filter {
    name   = "tag:Label"
    values = ["RDS_network"]
  }
}

data "aws_subnet_ids" "ssm_elb_subnets" {
  vpc_id = data.aws_vpc.vpc_ssm.id
  filter {
    name   = "tag:Label"
    values = ["ELB_network"]
  }
}

