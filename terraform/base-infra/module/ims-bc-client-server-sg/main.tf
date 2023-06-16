resource "null_resource" "client_egress_security_rules" {
  count = length(var.allowed_port_rules)

  triggers = {
    rule = element(var.allowed_port_rules, count.index)
    source_security_group_id = module.security_group_server.this_security_group_id
  }
}

resource "null_resource" "server_ingress_security_rules" {
  count = length(var.allowed_port_rules)

  triggers = {
    rule = element(var.allowed_port_rules, count.index)
    source_security_group_id = module.security_group_client.this_security_group_id
  }
}

module "security_group_client" {
  source = "terraform-aws-modules/security-group/aws"
  version = "3.3.0"
  name = format("%s_client_sg", var.sg_name_prefix)
  description = format("%s for clients", var.description_prefix)
  vpc_id = var.vpc_id

  computed_egress_with_source_security_group_id = null_resource.client_egress_security_rules.*.triggers
  number_of_computed_egress_with_source_security_group_id = var.number_of_allowed_port_rules

  # Workaround https://github.com/terraform-aws-modules/terraform-aws-security-group/issues/130
  egress_ipv6_cidr_blocks = []
}

module "security_group_server" {
  source = "terraform-aws-modules/security-group/aws"
  version = "3.3.0"
  name = format("%s_sg", var.sg_name_prefix)
  description = format("%s server side", var.description_prefix)
  vpc_id = var.vpc_id

  computed_ingress_with_source_security_group_id = null_resource.server_ingress_security_rules.*.triggers
  number_of_computed_ingress_with_source_security_group_id = var.number_of_allowed_port_rules
}

