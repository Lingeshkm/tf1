variable "sonar_name" {
  description = "Name of sonar instance"
  type = string
}

variable "launch_conf_name" {
  description = "Launch configuration name for the autoscaling group"
  type = string
}

variable "ami_id" {
  description = "AMI id for sonar"
  type = string
}

variable "ec2_instance_type" {
  description = "sonar ec2 type ie: t3a.medium"
  type = string
}

variable "sonar_sg" {
  description = "Security group for sonar"
  type = list
}

variable "sonar_lb_id" {
  description = "Load balancer id for sonar"
  type = list
}

variable "sonar_asg_name" {
  description = "Autoscaling group name for sonar"
  type = string
}

variable "sonar_asg_subnets" {
  description = "List of subnet for autoscaling group"
  type = list
}

variable "sonar_efs_id" {
  description = "EFS id for sonar data"
  type = string
}

variable "sonar_tag_name" {
  description = "Tag name for Sonar"
  type = string
}

variable "sonar_tag_environment" {
  description = "Environment tag for sonar"
  type = string
}

variable "sonar_tag_owner" {
  description = "Owner tag for sonar"
  type = string
}

variable "amibuild_service_linked_role_arn" {
  description = "The ARN for the service linked role to attach to the ASG for amibuild KMS key access"
  type = string
}
