variable "alb_name_tag" {
  description = "Identification of the ressource in our tags"
  type = string
}
variable "alb_environment" {
  description = "Which environment the ALB is running in"
  type        = string
  default = ""
}

variable "alb_owner" {
  description = "Who owns this infrastructure"
  type = string
  default = "BC"
}

variable "alb_vpc_id" {
  description = "VPC ID"
  type = string
}

variable "load_balancer_name" {
  description = "Name of the load balancer"
  type        = string
}

variable "alb_subnet_ids" {
  description = "ALB subnets ids"
  type        = list
}

variable "enable_alb_acces_logs" {
  description = "Turn on/off logging to s3"
  type = string
  default = "true"
}

variable "alb_certificate_arn" {
  description = "SSL certificate arn"
  type = string
}

variable "deletion_protection" {
  description = "Prevent Terraform from deleting the load balancer"
  type = string
  default = "false"
}

variable "internal_alb" {
  description = "load balancer is internal or externally facing"
  type = string
  default = "true"
}

variable "s3_log_bucket_name" {
  description = "Name of the s3 bucket to store ALB logs"
  type = string
}

variable "s3_log_prefix_name" {
  description = "Name of the prefix (folder) to store alb logs"
  type = string
  default = "alb-logs"
}

variable "sonar_alb_forward_host" {
  description = "Hostname to forward https request to"
  type = list
}

variable "sonar_alb_target_group_name" {
  description = "Name of the target group for ALB"
  type = string
  default = "sonarqube-target-group"
}

variable "rnd_ci_alb_forward_host" {
  description = "Hostname to forward https request to regarding rnd-ci"
  type = list
}

variable "rnd_ci_target_ip" {
  description = "IP address for the Jenkins instance to forward traffic to"
  type = string
}

variable "rnd_ci_alb_target_group_name" {
  description = "Name of the target group for ALB regarding rnd-ci"
  type = string
  default = "rnd-ci-target-group"
}

variable "infrabuild_alb_forward_host" {
  description = "Hostname to forward https request to regarding infrabuild"
  type = list
}

variable "infrabuild_target_ip" {
  description = "IP address for the infrabuild instance to forward traffic to"
  type = string
}

variable "infrabuild_alb_target_group_name" {
  description = "Name of the target group for ALB regarding infrabuild"
  type = string
  default = "infrabuild-target-group"
}

variable "rnd_artifacts_alb_forward_host" {
  description = "Hostname to forward https request to regarding rnd-artifacts"
  type = list
}

variable "rnd_artifacts_target_ip" {
  description = "IP address for the rnd-artifacts instance to forward traffic to"
  type = string
}

variable "rnd_artifacts_alb_target_group_name" {
  description = "Name of the target group for ALB regarding rnd-artifacts"
  type = string
  default = "rnd-artifacts-target-group"
}

