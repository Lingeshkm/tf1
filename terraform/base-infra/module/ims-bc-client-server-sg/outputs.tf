output "server_security_group_id" {
  description = "The ID of the server side security group"
  value = "${module.security_group_server.this_security_group_id}"
}

output "client_security_group_id" {
  description = "The ID of the client side security group"
  value = "${module.security_group_client.this_security_group_id}"
}
