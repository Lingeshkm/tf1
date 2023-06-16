output "id" {
  description = "The Amazon Resource Name (ARN) of the role."
  value       = "${aws_iam_service_linked_role.autoscaling_amibuild_role.id}"
}

output "arn" {
  description = "The Amazon Resource Name (ARN) specifying the role."
  value       = "${aws_iam_service_linked_role.autoscaling_amibuild_role.arn}"
}

output "grant_id" {
  description = "The unique identifier for the grant."
  value       = "${aws_kms_grant.ami_build_key_grant.grant_id}"
}

output "grant_token" {
  description = "The grant token for the created grant."
  value       = "${aws_kms_grant.ami_build_key_grant.grant_token}"
}
