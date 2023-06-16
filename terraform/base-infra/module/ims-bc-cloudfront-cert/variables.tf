variable "domain_name" {
  description = "The domain name to register the wildcard with"
  type = string
}

variable "zone_id" {
  description = "Route53 hosted zone id"
  type        = string
}

variable "common_tags" {
  description = "The set of tags to apply to generated resources"
  type = map(string)
  default = {}
}