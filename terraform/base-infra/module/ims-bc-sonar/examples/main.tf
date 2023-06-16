provider "aws" {
  region = "us-east-2"
  profile = "bc-dev"
}

#############################################################
# Data sources to get VPC and default security group details
#############################################################
data "aws_vpc" "vpc_id" {
 filter {
    name = "tag:ims:environment"
    values = ["dev"]
  }
}


module "test_sonar" {
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
