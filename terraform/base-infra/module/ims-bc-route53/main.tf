terraform {
  required_version = "> 0.12"
}

resource "aws_route53_record" "bitbucket_dns" {
  zone_id = var.zone_id
  name = "bitbucket"
  type = "A"
  ttl = "60"
  records = [var.bitbucket_ip_addr]
}

resource "aws_route53_record" "confluence_dns" {
  zone_id = var.zone_id
  name = "confluence"
  type = "A"
  ttl = "60"
  records = [var.confluence_ip_addr]
}

