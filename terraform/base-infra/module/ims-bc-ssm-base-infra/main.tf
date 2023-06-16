terraform {
  required_version = "> 0.12"
}

resource "aws_ssm_parameter" "ssm_config_default_env" {
  name  =   "/default_env"
  type  =   "String"
  description = "Return the environment to use by default"
  value =   var.key_prefix
  overwrite = "true"

  tags = {
    environment  = "${var.key_prefix}"
  }
}

resource "aws_ssm_parameter" "ssm_config_vpc_id" {
  name  =   "/base_infra/${var.key_prefix}/vpc_id"
  type  =   "String"
  description = "Return the VPC id for the environment"
  value =   var.vpc_id
  overwrite = "true"

  tags = {
    environment  = "${var.key_prefix}"
  }
}

resource "aws_ssm_parameter" "ssm_config_subnet_app_2a" {
  name  =   "/base_infra/${var.key_prefix}/subnet_1"
  type  =   "String"
  description = "Application subnet"
  value =   var.subnet_app_2a
  overwrite = "true"

  tags = {
    environment  = "${var.key_prefix}"
  }
}

resource "aws_ssm_parameter" "ssm_config_subnet_app_2b" {
  name  =   "/base_infra/${var.key_prefix}/subnet_2"
  type  =   "String"
  description = "Application subnet"
  value =   var.subnet_app_2b
  overwrite = "true"

  tags = {
    environment  = "${var.key_prefix}"
  }
}

resource "aws_ssm_parameter" "ssm_config_lambda_subnet_2c" {
  name  =   "/base_infra/${var.key_prefix}/lambda_subnet_1"
  type  =   "String"
  description = "The lambda subnets to leverage"
  value =   var.lambda_subnet_2c
  overwrite = "true"

  tags = {
    Label = "Lambda_network"
    environment  = "${var.key_prefix}"
  }
}

resource "aws_ssm_parameter" "ssm_config_lambda_subnet_2b" {
  name  =   "/base_infra/${var.key_prefix}/lambda_subnet_2"
  type  =   "String"
  description = "The lambda subnets to leverage"
  value =   var.lambda_subnet_2b
  overwrite = "true"

  tags = {
    Label = "Lambda_network"
    environment  = "${var.key_prefix}"
  }
}

resource "aws_ssm_parameter" "ssm_config_rds_subnet_2a" {
  name  =   "/base_infra/${var.key_prefix}/rds_subnet_2a"
  type  =   "String"
  description = "The RDS subnets in us-east-2a"
  value =   var.rds_subnet_2a
  overwrite = "true"

  tags = {
    Label = "RDS Network"
    environment  = "${var.key_prefix}"
  }
}

resource "aws_ssm_parameter" "ssm_config_rds_subnet_2b" {
  name  =   "/base_infra/${var.key_prefix}/rds_subnet_2b"
  type  =   "String"
  description = "The RDS subnets in us-east-2b"
  value =   var.rds_subnet_2b
  overwrite = "true"

  tags = {
    Label = "RDS Network"
    environment  = "${var.key_prefix}"
  }
}

resource "aws_ssm_parameter" "ssm_config_elb_subnet_2a" {
  name  =   "/base_infra/${var.key_prefix}/elb_subnet_2a"
  type  =   "String"
  description = "The ELB subnets in us-east-2a"
  value =   var.elb_subnet_2a
  overwrite = "true"

  tags = {
    Label = "ELB Network"
    environment  = "${var.key_prefix}"
  }
}
resource "aws_ssm_parameter" "ssm_config_elb_subnet_2b" {
  name  =   "/base_infra/${var.key_prefix}/elb_subnet_2b"
  type  =   "String"
  description = "The ELB subnets in us-east-2b"
  value =   var.elb_subnet_2b
  overwrite = "true"

  tags = {
    Label = "ELB Network"
    environment  = "${var.key_prefix}"
  }
}

resource "aws_ssm_parameter" "pg_buildinfo_read_user" {
  name  =   "/base_infra/${var.key_prefix}/pg_buildinfo_read_user"
  type  =   "String"
  description = "Postgres User Name(readonly) for the DB buildinfo"
  value =   var.pg_buildinfo_read_username
  overwrite = "true"

  tags = {
    environment  = "${var.key_prefix}"
  }
}

resource "aws_ssm_parameter" "pg_buildinfo_write_user" {
  name  =   "/base_infra/${var.key_prefix}/pg_buildinfo_write_user"
  type  =   "String"
  description = "Postgres User Name(readwrite) for the DB buildinfo"
  value =   var.pg_buildinfo_write_username
  overwrite = "true"

  tags = {
    environment  = "${var.key_prefix}"
  }
}

resource "aws_ssm_parameter" "rds_client_security_group" {
  name  =   "/base_infra/${var.key_prefix}/rds_client_security_group"
  type  =   "String"
  description = "Postgres Security Group to access it"
  value =   var.rds_client_security_group
  overwrite = "true"

  tags = {
    environment  = "${var.key_prefix}"
  }
}

resource "aws_ssm_parameter" "rnd_bcdb_fqdn" {
  name  =   "/base_infra/${var.key_prefix}/rnd_bcdb_fqdn"
  type  =   "String"
  description = "rnd-bcdb FQDN for this environment"
  value =   var.rnd_bcdb_fqdn
  overwrite = "true"

  tags = {
    environment  = "${var.key_prefix}"
  }
}

resource "aws_ssm_parameter" "vpc_cidr_block" {
  name = "/base_infra/${var.key_prefix}/vpc_cidr_block"
  type = "String"
  description = "cidr_block for environment"
  value = var.vpc_cidr_block
  tags = {
    environment  = "${var.key_prefix}"
  }
}

resource "aws_ssm_parameter" "all_outbound_security_group" {
  name  =   "/base_infra/${var.key_prefix}/all_outbound_security_group"
  type  =   "String"
  description = "All outbound allowing to connect anywhere"
  value =   var.all_outbound_security_group
  overwrite = "true"

  tags = {
    environment  = "${var.key_prefix}"
  }
}

resource "aws_ssm_parameter" "ev_latest_release_manifest_url" {
  name  =   "/base_infra/${var.key_prefix}/ev_latest_release_manifest_url"
  type  =   "String"
  description = "URL pointing to current EV release manifest"
  value =   var.ev_latest_release_manifest_url
  overwrite = "true"

  tags = {
    environment  = "${var.key_prefix}"
  }
}

# ReleaseInfo SSM Bundle
data "template_file" "release_info_ssm_template" {
  template = "${file("${path.module}/templates/release_info_ssm.tpl")}"
  vars = {
    ev_latest_release_manifest_url = "${var.ev_latest_release_manifest_url}"
    buildinfo_api = "${var.buildinfo_api}"
  }
}
resource "aws_ssm_parameter" "release_info_bundle" {
  name        = "/app/${var.key_prefix}/release_info"
  type        = "String"
  description = "Parameters bundle for Release Info"
  value       = data.template_file.release_info_ssm_template.rendered

  tags = {
    Environment  = "${var.key_prefix}"
  }
}
