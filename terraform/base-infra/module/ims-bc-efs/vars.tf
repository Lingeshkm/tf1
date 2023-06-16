variable "environment_tag" {
  description = "Environment tag name"
  type        = string
}

variable "environment" {
  description = "Environment prefix name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID use by EFS"
  type = string
}

variable "efs_subnet_id_1" {
  description = "EFS mount subnet 1."
  type        = string
}
variable "efs_subnet_id_2" {
  description = "EFS mount subnet 2."
  type        = string
}

