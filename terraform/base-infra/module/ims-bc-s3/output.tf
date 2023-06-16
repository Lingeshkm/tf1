output "bucket_name" {
  description = "Bucket Name"
  value       = "${aws_s3_bucket.bc-bucket-res.bucket}"
}

output "bucket_arn" {
  description = "Bucket ARN"
  value       = "${aws_s3_bucket.bc-bucket-res.arn}"
}
