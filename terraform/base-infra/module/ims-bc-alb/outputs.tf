output "alb_dns_name" {
  description = "AWS dns name for the alb"
  value       = "${aws_lb.app_lb.dns_name}"
}

output "alb_zone_id" {
  description = "Zone of the ALB"
  value       = "${aws_lb.app_lb.zone_id}"
}

output "alb_name" {
  description = "Name of the alb"
  value = "${aws_lb.app_lb.name}"
}

output "alb_id" {
  value = "${aws_lb.app_lb.id}"
}

output "alb_target_group_arns" {
  value = "${aws_lb_target_group.https_instance_target_group.arn}"
}

output "alb_sg_id" {
  description = "ALB security group for server"
  value = "${module.security_group_server.this_security_group_id}"
}

output "alb_client_sg_id" {
  description = "ALB security group for clients"
  value = "${module.security_group_client.this_security_group_id}"
}