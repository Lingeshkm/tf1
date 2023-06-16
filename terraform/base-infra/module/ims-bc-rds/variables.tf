variable "db_name" {
  description = "DB name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "pg_engine_version" {
  description = "Postgresql Engine version"
  type        = string
}

variable "pg_engine_major_version" {
  description = "Postgresql Engine Major version"
  type        = string
}

variable "pg_family_version" {
  description = "Postgresql family version"
  type        = string
}

variable "pg_instance_class" {
  description = "Postgresql instance class"
  type        = string
}

variable "allow_major_version_upgrade" {
  description = "Allow major version upgrade"
  type        = bool
}

variable "pg_admin_pw" {
  description = "Postgresql Admin PW"
  type        = string
}

variable "db_subnet_ids" {
  description = "DB subnets ids"
  type        = list
}

variable "ingress_cidr" {
  description = "Ingress cidr"
  type        = list
}

variable "egress_rules" {
  description = "egress rules"
  type        = list
}

variable "db_storage_size" {
  description = "DB storage size(GB)"
  type        = string
}

variable "max_db_allocated_storage" {
  description = "Maximum DB storage size(GB)"
  type        = string
  default     = "100"
}

variable "db_backup_retention_period" {
  description = "DB backup retention period"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC cidr"
  type        = string
}

variable "environment" {
  description = "Environment tag name"
  type        = string
}

variable "db_monitoring_interval" {
  description = "Interval for RDS monitoring"
  type        = string
}

variable "db_delete_protection" {
  description = "RDS delete protection true/false"
  type        = string
  default     = "true"
}

variable "multi_az" {
  description = "Turn on/off Multiple Zone support"
  type        = string
}


