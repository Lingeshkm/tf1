variable "vpc_environment" {
  description = "Which environment the VPC is running in"
  type        = string
  default = ""
}

variable "vpc_tag" {
  description = "VPC tag name"
  type        = string

  default = ""
}

variable "vpc_subnets_app_2a" {
  description = "A list of intra subnets"
  type        = string
  default     = ""
}

variable "vpc_subnets_app_2b" {
  description = "A list of intra subnets"
  type        = string
  default     = ""
}

variable "vpc_subnets_lambda_2c" {
  description = "A list of intra subnets"
  type        = string
  default     = ""
}

variable "vpc_subnets_lambda_2b" {
  description = "A list of intra subnets"
  type        = string
  default     = ""
}

variable "vpc_subnets_rds_2a" {
  description = "A list of intra subnets"
  type        = string
  default     = ""
}

variable "vpc_subnets_rds_2b" {
  description = "A list of intra subnets"
  type        = string
  default     = ""
}

variable "vpc_subnets_elb_2a" {
  description = "A list of intra subnets"
  type        = string
  default     = ""
}

variable "vpc_subnets_elb_2b" {
  description = "A list of intra subnets"
  type        = string
  default     = ""
}

variable "vpc_subnets_build_2a" {
  description = "A list of intra subnets"
  type        = string
  default     = ""
}

variable "vpc_subnets_build_2b" {
  description = "A list of intra subnets"
  type        = string
  default     = ""
}

variable "vpc_subnets_endpoints_2a" {
  description = "A list of intra subnets"
  type        = string
  default     = ""
}

variable "vpc_subnets_endpoints_2b" {
  description = "A list of intra subnets"
  type        = string
  default     = ""
}



