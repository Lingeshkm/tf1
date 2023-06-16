output "ims_bc_release_bucket_name" {
  description = "Bucket Name"
  value       = "${aws_s3_bucket.ims-bc-release-s3.bucket}"
}

output "bucket_arn" {
  description = "Bucket ARN"
  value       = "${aws_s3_bucket.ims-bc-release-s3.arn}"
}
