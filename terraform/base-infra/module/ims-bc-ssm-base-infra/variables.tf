variable "vpc_id" {
  description = "vpc id for ssm"
}

variable "subnet_app_2a" {
  description = "subnet for ssm"
  type = string
}

variable "subnet_app_2b" {
  description = "subnet for ssm"
  type = string
}

variable "lambda_subnet_2c" {
  description = "lambda subnets for ssm"
  type = string
}

variable "lambda_subnet_2b" {
  description = "lambda subnets for ssm"
  type = string
}

variable "rds_subnet_2a" {
  description = "RDS subnets for ssm"
  type = string
}

variable "rds_subnet_2b" {
  description = "RDS subnets for ssm"
  type = string
}

variable "elb_subnet_2a" {
  description = "ELB subnets for ssm"
  type = string
}

variable "elb_subnet_2b" {
  description = "ELB subnets for ssm"
  type = string
}

variable "key_prefix" {
  description = "Environment key prefix"
}

variable "pg_buildinfo_read_username" {
  description = "Postgres User Name(readonly) for the DB buildinfo"
  type = string
}

variable "pg_buildinfo_write_username" {
  description = "Postgres User Name(readwrite) for the DB buildinfo"
  type = string
}

variable "rds_client_security_group" {
  description = "RDS security group to access it"
  type = string
}

variable "rnd_bcdb_fqdn" {
  description = "rnd-bcdb FQDN for this environment"
  type = string
}

variable "vpc_cidr_block" {
  description = "cidr_block for environment"
  type = string
}

variable "all_outbound_security_group" {
  description = "Allow to connect anywhere"
  type = string
}

variable "ev_latest_release_manifest_url" {
  description = "URL pointing to current EV release manifest"
  type = string
}

variable "buildinfo_api" {
  description = "BuildInfo API URL"
  type = string
}
