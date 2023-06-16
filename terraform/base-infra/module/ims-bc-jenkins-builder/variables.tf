variable "jenkins_name" {
  description = "Name of jenkins instance"
  type = string
}

variable "ami_id" {
  description = "AMI id for jenkins"
  type = string
}

variable "ec2_instance_type" {
  description = "jenkins ec2 type ie: t3a.medium"
  type = string
}

variable "instance_count" {
  description = "The amount of instance to launch"
  type = string
}

variable "vpc_security_group_ids" {
  description = "List of security groups"
  type = list
}

variable "jenkins_tag_name" {
  description = "Tag name for jenkins"
  type = string
}

variable "ssh_key_name" {
  description = "SSH keypair"
  type = string
}

variable "cpu_credits" {
  description = "Cpu credits mode"
  type = string
}

variable "ebs_optimized" {
  description = "value"
  type = string
}

variable "subnet_ids" {
  description = "List of subnets ids to use"
  type = list
}

variable "jenkins_tag_environment" {
  description = "Environment tag for jenkins"
  type = string
}

variable "jenkins_tag_owner" {
  description = "Owner tag for jenkins"
  type = string
}

variable "amibuild_service_linked_role_arn" {
  description = "The ARN for the service linked role to attach to the ASG for amibuild KMS key access"
  type = string
}
