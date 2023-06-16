terraform {
  required_version = "> 0.12"
}

locals {
  application_label = "Application_network"
  lambda_label = "Lambda_network"
  db_label = "RDS_network"
  elb_label = "ELB_network"
  build_label = "BUILD network"
  endpoints_label = "ENDPOINTS network"
  rnd_ci_ip = "10.90.129.63/32"
  rnd_testci_ip = "10.90.129.74/32"
  rnd_logs_ip = "10.90.129.19/32"
  ims_network = "10.90.0.0/16"
}

data "aws_region" "current" {}

data "aws_caller_identity" "my_identity" {}

data "aws_vpc" "vpc_id" {
 filter {
    name = "tag:ims:environment"
    values = [var.vpc_environment]
  }
}

resource "aws_subnet" "subnet_app_2a" {
  vpc_id = data.aws_vpc.vpc_id.id
  cidr_block = var.vpc_subnets_app_2a
  availability_zone = "us-east-2a"

  tags = {
    Name = "App SN 2a"
    Environment = "${var.vpc_tag}"
    Label = local.application_label
    Owner = "BC"
  }
}

resource "aws_subnet" "subnet_app_2b" {
  vpc_id = data.aws_vpc.vpc_id.id
  cidr_block = var.vpc_subnets_app_2b
  availability_zone = "us-east-2b"

  tags = {
    Name = "App SN 2b"
    Environment = var.vpc_tag
    Label = local.application_label
    Owner = "BC"
  }
}

resource "aws_subnet" "subnet_lambda_2c" {
  vpc_id = data.aws_vpc.vpc_id.id
  cidr_block = var.vpc_subnets_lambda_2c
  availability_zone = "us-east-2c"

  tags = {
    Name = "Lambda SN 2c"
    Environment = var.vpc_tag
    Label = local.lambda_label
    Owner = "BC"
  }
}

resource "aws_subnet" "subnet_lambda_2b" {
  vpc_id = data.aws_vpc.vpc_id.id
  cidr_block = var.vpc_subnets_lambda_2b
  availability_zone = "us-east-2b"

  tags = {
    Name = "Lambda SN 2b"
    Environment = var.vpc_tag
    Label = local.lambda_label
    Owner = "BC"
  }
}

resource "aws_subnet" "subnet_rds_2a" {
  vpc_id = data.aws_vpc.vpc_id.id
  cidr_block = var.vpc_subnets_rds_2a
  availability_zone = "us-east-2a"

  tags = {
    Name = "RDS SN 2a"
    Environment = var.vpc_tag
    Label = local.db_label
    Owner = "BC"
  }
}

resource "aws_subnet" "subnet_rds_2b" {
  vpc_id = data.aws_vpc.vpc_id.id
  cidr_block = var.vpc_subnets_rds_2b
  availability_zone = "us-east-2b"

  tags = {
    Name = "RDS SN 2b"
    Environment = var.vpc_tag
    Label = local.db_label
    Owner = "BC"
  }
}

resource "aws_subnet" "subnet_elb_2a" {
  vpc_id = data.aws_vpc.vpc_id.id
  cidr_block = var.vpc_subnets_elb_2a
  availability_zone = "us-east-2a"

  tags = {
    Name = "ELB SN 2a"
    Environment = var.vpc_tag
    Label = local.elb_label
    Owner = "BC"
  }
}

resource "aws_subnet" "subnet_elb_2b" {
  vpc_id = data.aws_vpc.vpc_id.id
  cidr_block = var.vpc_subnets_elb_2b
  availability_zone = "us-east-2b"

  tags = {
    Name = "ELB SN 2b"
    Environment = var.vpc_tag
    Label = local.elb_label
    Owner = "BC"
  }
}

resource "aws_subnet" "subnet_build_2a" {
  vpc_id = data.aws_vpc.vpc_id.id
  cidr_block = var.vpc_subnets_build_2a
  availability_zone = "us-east-2a"

  tags = {
    Name = "BUILD SN 2a"
    Environment = var.vpc_tag
    Label = local.build_label
    Owner = "BC"
  }
}

resource "aws_subnet" "subnet_build_2b" {
  vpc_id = data.aws_vpc.vpc_id.id
  cidr_block = var.vpc_subnets_build_2b
  availability_zone = "us-east-2b"

  tags = {
    Name = "BUILD SN 2b"
    Environment = var.vpc_tag
    Label = local.build_label
    Owner = "BC"
  }
}

resource "aws_subnet" "subnet_endpoints_2a" {
  vpc_id = data.aws_vpc.vpc_id.id
  cidr_block = var.vpc_subnets_endpoints_2a
  availability_zone = "us-east-2a"

  tags = {
    Name = "ENDPOINTS SN 2a"
    Environment = var.vpc_tag
    Label = local.endpoints_label
    Owner = "BC"
  }
}

resource "aws_subnet" "subnet_endpoints_2b" {
  vpc_id = data.aws_vpc.vpc_id.id
  cidr_block = var.vpc_subnets_endpoints_2b
  availability_zone = "us-east-2b"

  tags = {
    Name = "ENDPOINTS SN 2b"
    Environment = var.vpc_tag
    Label = local.endpoints_label
    Owner = "BC"
  }
}
#########
# Route53
#########

resource "aws_security_group" "route53_resolver_endpoint_sg" {
  name = "route53_resolver_endpoint_sg"
  description = "Allow the office to use the private VPC route 53"
  vpc_id = data.aws_vpc.vpc_id.id

  ingress {
    to_port = 53
    from_port = 53
    protocol = "udp"
    cidr_blocks = ["10.0.0.0/8"]

    description = "Allow the office to use the private VPC route 53"
  }

  egress {
    to_port = 53
    from_port = 53
    protocol = "udp"
    cidr_blocks = ["10.0.0.0/8"]

    description = "Allow connections to the office DNS"
  }


  tags = {
    Name = "route53_resolver_endpoint_sg"
  }
}

resource "aws_route53_resolver_endpoint" "ims_route53_outbound_resolver_endpoint" {
  name      = "ims-internal-dns-rule"
  direction = "OUTBOUND"

  security_group_ids = [aws_security_group.route53_resolver_endpoint_sg.id]

  ip_address {
    subnet_id = aws_subnet.subnet_app_2a.id
  }
  ip_address {
    subnet_id = aws_subnet.subnet_app_2b.id
  }
  tags = {
    Environment = var.vpc_tag
  }
}

resource "aws_route53_resolver_rule" "ims_route53_endpoint_rule" {
  domain_name = "intelerad.com"
  name = "ims-internal-dns-rule"
  rule_type = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.ims_route53_outbound_resolver_endpoint.id
  target_ip {
    ip   = "10.90.100.36"
  }
  target_ip {
    ip   = "10.90.100.37"
  }
  tags = {
    Environment = var.vpc_tag
  }
}

resource "aws_route53_resolver_rule_association" "ims_route53_resolver_rule_association" {
  resolver_rule_id = aws_route53_resolver_rule.ims_route53_endpoint_rule.id
  vpc_id           = data.aws_vpc.vpc_id.id
}

################
# Security Group
################

resource "aws_security_group" "sg_endpoint" {
  name = "sg_vpc_endpoint"
  description = "Security group for vpc endpoint service"
  vpc_id = data.aws_vpc.vpc_id.id
  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = [data.aws_vpc.vpc_id.cidr_block]
  }
  tags = {
    Environment = var.vpc_tag
    Name = "sg_endpoint"
  }
}

resource "aws_security_group" "all_outbound_sg" {
  name = "all_outbound_sg"
  description = "Allow only outbound traffic to everything"
  vpc_id = data.aws_vpc.vpc_id.id
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Environment = var.vpc_tag
    Name = "all_outbound_sg"
  }
}

resource "aws_security_group" "jenkins-master_sg" {
  name = "jenkins-master_sg"
  description = "Allow only ssh inbound for rnd-ci/testci and rnd-logs hosts"
  vpc_id = data.aws_vpc.vpc_id.id
  ingress {
    description = "On-Prem Intelerad jenkins hosts"
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = [local.rnd_ci_ip, local.rnd_testci_ip, local.rnd_logs_ip]
  }
  tags = {
    Environment = var.vpc_tag
    Name = "jenkins-master_sg"
    Owner = "BC"
  }
}

resource "aws_security_group" "jenkins-builder-rdp_sg" {
  name = "jenkins-builder-rdp_sg"
  description = "Allow RDP inbound for intelerad-on-prem hosts"
  vpc_id = data.aws_vpc.vpc_id.id
  ingress {
    description = "On-Prem Intelerad hosts"
    from_port = 3389
    protocol = "tcp"
    to_port = 3389
    cidr_blocks = [local.ims_network]
  }
  tags = {
    Environment = var.vpc_tag
    Name = "jenkins-builder-rdp_sg"
    Owner = "BC"
  }
}

##########
# Key Pair
##########

resource "aws_key_pair" "jenkins-ci-ssh-key" {
  key_name = "jenkins-ci-master"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2SAO6T6tO58PW0+xadiHNaRja6dd08o+gRigtCM6nte6K807PIQx9eoM1ejciLEvDthmY5/k6XkqgBJH8tK/sdtyO1DBI/ER+/B2mQBReQ0A/RvQkc4L7PNyETkSV2cJiUjg4mfmTippW7tFbDGLHrtkzqXs+HTx3X9GhHGXlLvJkCjdHj3/+epFYr0G8YF1A+KMRr57dYJSFeGF2TfWADofaLccx66IyY+d09RZAzIWuRcDucmmtdh3yYQlXTYe8AO04yR/Z5bcfGiMLQEcrY8lxczamyUiUhTTDjpQBsrD876t+ML+4+2UTJ//Dq4xt3IGouOLkSGXAJLcXYeX3 jenkins@rnd-ci.intelerad.com"
}


##############
# VPC Endpoint
##############
resource "aws_vpc_endpoint" "ssm_endpoint" {
  service_name = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_id = data.aws_vpc.vpc_id.id
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.subnet_lambda_2c.id, aws_subnet.subnet_lambda_2b.id]
  security_group_ids = [aws_security_group.sg_endpoint.id]
}

resource "aws_vpc_endpoint" "secret_manager_endpoint" {
  service_name = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_id = data.aws_vpc.vpc_id.id
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.subnet_lambda_2c.id, aws_subnet.subnet_lambda_2b.id]
  security_group_ids = [aws_security_group.sg_endpoint.id]
}

resource "aws_vpc_endpoint" "cloudwatch_monitoring_endpoint" {
  service_name = "com.amazonaws.${data.aws_region.current.name}.monitoring"
  vpc_id = data.aws_vpc.vpc_id.id
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.subnet_app_2a.id, aws_subnet.subnet_app_2b.id]
  security_group_ids = [aws_security_group.sg_endpoint.id]
}

resource "aws_vpc_endpoint" "cloudwatch_logs_endpoint" {
  service_name = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_id = data.aws_vpc.vpc_id.id
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.subnet_app_2a.id, aws_subnet.subnet_app_2b.id]
  security_group_ids = [aws_security_group.sg_endpoint.id]
}

# We do not needs it now. We'll activate it later.
#
#resource "aws_vpc_endpoint" "cloudwatch_events_endpoint" {
#  service_name = "com.amazonaws.${data.aws_region.current.name}.events"
#  vpc_id = "${data.aws_vpc.vpc_id.id}"
#  vpc_endpoint_type = "Interface"
#  private_dns_enabled = true
#  subnet_ids          = ["${aws_subnet.subnet_app_2a.id}", "${aws_subnet.subnet_app_2b.id}"]
#  security_group_ids = ["${aws_security_group.sg_endpoint.id}"]
#}

resource "aws_vpc_endpoint" "sqs_endpoint" {
  service_name = "com.amazonaws.${data.aws_region.current.name}.sqs"
  vpc_id = data.aws_vpc.vpc_id.id
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.subnet_endpoints_2a.id, aws_subnet.subnet_endpoints_2b.id]
  security_group_ids = [aws_security_group.sg_endpoint.id]
}

resource "aws_vpc_endpoint" "dynamodb_endpoint" {
  service_name = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_id = data.aws_vpc.vpc_id.id
  vpc_endpoint_type = "Gateway"
  route_table_ids = [data.aws_vpc.vpc_id.main_route_table_id]
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_id = data.aws_vpc.vpc_id.id
  vpc_endpoint_type = "Gateway"
  route_table_ids = [data.aws_vpc.vpc_id.main_route_table_id]
}
