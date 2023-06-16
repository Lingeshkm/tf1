terraform {
  required_version = "> 0.12"
}

resource "random_string" "random_buildinfo_read_pw" {
  length = 16
  special = true
}

resource "aws_secretsmanager_secret" "buildinfo_read" {
  name =   var.buildinfo_read
  description = "Password for ${var.buildinfo_read} Postgresql user"

  tags = {
    environment  = var.key_prefix
  }
}

resource "aws_secretsmanager_secret_version" "buildinfo_read" {
  secret_id =  aws_secretsmanager_secret.buildinfo_read.id
  secret_string = random_string.random_buildinfo_read_pw.result
}

resource "random_string" "random_buildinfo_write_pw" {
  length = 16
  special = true
}

resource "aws_secretsmanager_secret" "buildinfo_write" {
  name =   var.buildinfo_write
  description = "Password for ${var.buildinfo_write} Postgresql user"

  tags = {
    environment  = var.key_prefix
  }
}

resource "aws_secretsmanager_secret_version" "buildinfo_write" {
  secret_id =   aws_secretsmanager_secret.buildinfo_write.id
  secret_string = random_string.random_buildinfo_write_pw.result
}

resource "random_string" "random_rds_admin_pw" {
  length = 16
  special = true
}

resource "aws_secretsmanager_secret" "rds_admin_pw" {
  name =   "/base_infra/${var.key_prefix}/rds_admin_pw"
  description = "Password for RDS admin user"

  tags = {
    environment  = var.key_prefix
  }
}

resource "aws_secretsmanager_secret_version" "rds_admin_pw" {
  secret_id =   aws_secretsmanager_secret.rds_admin_pw.id
  secret_string = random_string.random_rds_admin_pw.result
}


resource "random_string" "sonarqube_secret_random_string" {
  length = 16
  /* Because we set the password in docker-compose.yml that will pass
     this password in a bash variable, we need to remove all the special
     char used for Sonar password.
  */
  special = false
}

data "template_file" "sonarqube_secret_template" {
  template = file("${path.module}/templates/sonarqube_secret.tpl")
  vars = {
    sonarqube_password = random_string.sonarqube_secret_random_string.result
    postgres_database_host = var.postgres_host
    postgres_db_instance_id = var.postgres_instance_id
  }
}

resource "aws_secretsmanager_secret" "sonarqube_secret" {
  name =   "/base_infra/${var.key_prefix}/pg_sonarqube_readwrite"
  description = "Password for the SonarQube RDS connection"

  tags = {
    Environment  = var.key_prefix
  }
}

resource "aws_secretsmanager_secret_version" "sonarqube_secret_version" {
  secret_id =   aws_secretsmanager_secret.sonarqube_secret.id
  secret_string = data.template_file.sonarqube_secret_template.rendered
}
