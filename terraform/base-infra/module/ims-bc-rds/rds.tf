terraform {
  required_version = "> 0.12"
}


module "security_group_outbound" {
  source = "terraform-aws-modules/security-group/aws"
  version = "3.3.0"
  name = "sg_rds_pg_clients"
  description = "Security group for RDS Postgres Clients"
  vpc_id = "${var.vpc_id}"
  egress_cidr_blocks = ["${var.vpc_cidr}"]
  egress_rules = ["postgresql-tcp", "https-443-tcp"]
  egress_ipv6_cidr_blocks = []
}

module "security_group" {
  source = "terraform-aws-modules/security-group/aws"
  version = "3.3.0"
  name = "rds_sg"
  description = "Security group RDS instance"
  vpc_id = "${var.vpc_id}"
  computed_ingress_with_source_security_group_id = [
    {
      rule  = "postgresql-tcp"
      source_security_group_id = "${module.security_group_outbound.this_security_group_id}"
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1
  ingress_cidr_blocks = "${var.ingress_cidr}"
  ingress_rules = ["postgresql-tcp"]
  egress_rules = "${var.egress_rules}"
}

#####
# DB
#####
module "db" {
  source = "terraform-aws-modules/rds/aws"
  version = "2.20.0"
  identifier = "${var.db_name}"
  engine            = "postgres"
  engine_version    = "${var.pg_engine_version}"
  instance_class    = "${var.pg_instance_class}"
  allow_major_version_upgrade = "${var.allow_major_version_upgrade}"
  allocated_storage = "${var.db_storage_size}"
  max_allocated_storage = "${var.max_db_allocated_storage}"
  storage_encrypted = true
  apply_immediately = false
  parameters = [
    {
      apply_method = "pending-reboot"
      name = "rds.force_ssl"
      value = "1"
    }
  ]

  name = "${var.db_name}"

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  username = "postgres"

  password = "${var.pg_admin_pw}"
  port     = "5432"

  vpc_security_group_ids = ["${module.security_group.this_security_group_id}"]

  maintenance_window = "Sat:05:00-Sat:08:00"
  backup_window      = "01:00-04:00"

  backup_retention_period = "${var.db_backup_retention_period}"

  tags = {
    Environment = "${var.environment}"
  }

  # DB subnet group
  subnet_ids = "${var.db_subnet_ids}"

  # DB parameter group
  family = "${var.pg_family_version}"

  # DB option group
  major_engine_version = "${var.pg_engine_major_version}"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "${var.db_name}"

  monitoring_interval = "${var.db_monitoring_interval}"
  # Database Deletion Protection
  deletion_protection = "${var.db_delete_protection}"
  multi_az = "${var.multi_az}"
}
