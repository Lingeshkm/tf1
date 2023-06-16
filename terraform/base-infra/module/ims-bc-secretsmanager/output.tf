output "rds_admin_pw_secretmanager_secret_id" {
  description = "RDS Admin secretmanager id"
  value       = "${aws_secretsmanager_secret.rds_admin_pw.id}"
}

output "sonarqube_secret_id" {
  description = "The secret id for the sonarqube password"
  value       = "${aws_secretsmanager_secret.sonarqube_secret.id}"
}