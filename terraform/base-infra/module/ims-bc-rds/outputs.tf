output "rds_instance_address" {
  description = "the RDS endpoint"
  value       = "${module.db.this_db_instance_address}"
}

output "rds_outbound_security_group_id" {
  description = "Outbound SG to be able to connect to RDS"
  value       = "${module.security_group_outbound.this_security_group_id}"
}
