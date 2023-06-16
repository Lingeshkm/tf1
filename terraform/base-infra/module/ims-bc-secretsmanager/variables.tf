
variable "key_prefix" {
  description = "Environment key prefix"
}

variable "buildinfo_read" {
  description = "The name of your readonly secrets manager's name"
  type = string
  default = "pg_buildinfo_readonly"
}

variable "buildinfo_write" {
  description = "The name of your readwrite SecretsManager name"
  type = string
  default = "pg_buildinfo_readwrite"
}

variable "postgres_host" {
  description = "The hostname associated with our PostgreSQL instance"
  type = string
}

variable "postgres_instance_id" {
  description = "The instance identifier of the PostgreSQL database"
  type = string
  default = "bcdb"
}

