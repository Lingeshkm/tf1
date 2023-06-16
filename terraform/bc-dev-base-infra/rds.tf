module "ims-bc-rds" {
  source = "../base-infra/module/ims-bc-rds"

  environment             = local.environment
  vpc_id                  = data.aws_vpc.vpc_ssm.id
  vpc_cidr                = data.aws_vpc.vpc_ssm.cidr_block
  db_name                 = "bcdb"
  pg_instance_class       = "db.t2.medium"
  pg_engine_version       = "12.8"
  pg_engine_major_version = "12"
  pg_family_version       = "postgres12"
  allow_major_version_upgrade = false
  pg_admin_pw             = data.aws_secretsmanager_secret_version.rds_admin_pw.secret_string
  db_subnet_ids           = data.aws_subnet_ids.ssm_rds_subnets.ids
  ingress_cidr            = ["10.90.129.19/32"]
  egress_rules            = ["all-all"]
  db_storage_size         = "30"
  multi_az                = "false"

  # No backup on staging or dev.
  db_backup_retention_period = "0"
  db_monitoring_interval     = "0"
  db_delete_protection       = "false"
}

data "aws_secretsmanager_secret_version" "rds_admin_pw" {
  secret_id = module.secretsmanager.rds_admin_pw_secretmanager_secret_id
}

data "aws_route53_zone" "route53_zone" {
  name = "${local.bc_domain}."
}

resource "aws_route53_record" "bcdb_dns" {
  zone_id = data.aws_route53_zone.route53_zone.id
  name    = "rnd-bcdb"
  type    = "CNAME"
  records = [module.ims-bc-rds.rds_instance_address]
  ttl     = "300"
}

