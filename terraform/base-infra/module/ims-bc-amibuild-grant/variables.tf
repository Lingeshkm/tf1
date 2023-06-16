variable "environment" {
  description = "Which environment is the grant being performed from"
  type        = string
}

variable "key_arn" {
  description = "The fully qualified arn for the production amibuild KMS key"
  type        = string
}
