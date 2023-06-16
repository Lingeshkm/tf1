variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "sg_name_prefix" {
  description = "The prefix of the security group, we will append _sg or _client_sg to this"
  type        = string
}

variable "description_prefix" {
  description = "A prefixed version of the description of security group"
  type        = string
  default     = "Security Group managed by Terraform"
}

# To see the allowed list of values provided see the rules.tf from the aws security group module
# https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/master/rules.tf
variable "allowed_port_rules" {
  description = "List of port rules that will be opened on the server and client"
  type        = list
  default     = []
}

variable "number_of_allowed_port_rules" {
  description = "Number of computed allowed port rules to create"
  type        = string
  default     = 0
}
