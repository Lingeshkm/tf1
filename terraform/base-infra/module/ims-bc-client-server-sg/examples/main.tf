provider "aws" {
  region = "ca-central-1"
  profile = "bc-dev"
}

#############################################################
# Data sources to get VPC and default security group details
#############################################################
data "aws_vpc" "default" {
  default = true
}

locals {
    # Allowed values are available from here:
    # https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/master/rules.tf
    shared_ports = ["postgresql-tcp", "https-443-tcp"]
}

module "test_dual_sg" {
  source = "../"

  sg_name_prefix = "sclark-test"
  description_prefix = "Test security group"
  vpc_id = "${data.aws_vpc.default.id}"

  allowed_port_rules = "${local.shared_ports}"
  number_of_allowed_port_rules = "${length(local.shared_ports)}"
}

output "server_security_group_id" {
  value = "${module.test_dual_sg.server_security_group_id}"
}

output "client_security_group_id" {
  value = "${module.test_dual_sg.client_security_group_id}"
}
