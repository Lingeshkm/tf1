terraform {
  required_version = "> 0.12"
}

locals {
  sonar_name = "efs_sonar"
  allowed_port = ["nfs-tcp"]
}

resource "aws_efs_file_system" "efs_sonar" {
  creation_token = local.sonar_name
  encrypted = true

  tags = {
    Name = local.sonar_name
    Environment = var.environment_tag
  }
}

module "efs_sonar_dual_sg" {
  source = "../ims-bc-client-server-sg/"

  sg_name_prefix = local.sonar_name
  description_prefix = "Sonar security group"
  vpc_id = var.vpc_id
  allowed_port_rules = local.allowed_port
  number_of_allowed_port_rules = length(local.allowed_port)
}

resource "aws_efs_mount_target" "efs_mount_sonar_subnet1" {
  file_system_id = aws_efs_file_system.efs_sonar.id
  subnet_id      = var.efs_subnet_id_1
  security_groups = [module.efs_sonar_dual_sg.server_security_group_id]
}

resource "aws_efs_mount_target" "efs_mount_sonar_subnet2" {
  file_system_id = aws_efs_file_system.efs_sonar.id
  subnet_id      = var.efs_subnet_id_2
  security_groups = [module.efs_sonar_dual_sg.server_security_group_id]
}

