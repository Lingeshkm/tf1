output "efs_sonar_id" {
  value = "${aws_efs_file_system.efs_sonar.id}"
}

output "efs_server_security_group_id" {
  description = "The ID of the server side security group"
  value = "${module.efs_sonar_dual_sg.server_security_group_id}"
}

output "efs_client_security_group_id" {
  description = "The ID of the client side security group"
  value = "${module.efs_sonar_dual_sg.client_security_group_id}"
}
