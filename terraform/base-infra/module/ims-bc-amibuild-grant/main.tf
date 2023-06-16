resource "aws_iam_service_linked_role" "autoscaling_amibuild_role" {
  aws_service_name = "autoscaling.amazonaws.com"
  description = "A service linked role for autoscaling that has access to the production amibuild KMS key"
  custom_suffix = "BC_AMIBUILD"

  lifecycle {
    ignore_changes = [custom_suffix]
  }
}

resource "aws_kms_grant" "ami_build_key_grant" {
  name              = "${var.environment}_ami-build-key-grant"
  key_id            = var.key_arn
  grantee_principal = aws_iam_service_linked_role.autoscaling_amibuild_role.arn
  operations        = ["Encrypt", "Decrypt", "ReEncryptFrom", "ReEncryptTo",
                       "GenerateDataKey", "GenerateDataKeyWithoutPlaintext",
                       "DescribeKey", "CreateGrant"]
}
