resource "aws_kms_key" "ami-build-kms-key" {
  description             = "KMS key for building AMI's"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  # Allow all operations within the production account (414952023392)
  #  - Allow decryption and simple usage of the key within the other accounts
  #     - 792686863424 (staging)
  #     - 429656490274 (dev)
  policy = <<KMS_BUILD__KEY_POLICY
{
    "Version": "2012-10-17",
    "Id": "terraform-policy-1",
    "Statement": [
        {
            "Sid": "Allow administration of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::414952023392:root"
            },
            "Action": [
                "kms:Create*",
                "kms:Describe*",
                "kms:Enable*",
                "kms:List*",
                "kms:Put*",
                "kms:Update*",
                "kms:Revoke*",
                "kms:Disable*",
                "kms:Get*",
                "kms:Delete*",
                "kms:ScheduleKeyDeletion",
                "kms:CancelKeyDeletion"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow usage of the key solely for EC2",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::414952023392:root"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:DescribeKey"
            ],
            "Resource": "*",
            "Condition": {
                "ForAnyValue:StringEquals": {
                    "kms:ViaService":[
                        "ec2.us-east-2.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::429656490274:root",
                    "arn:aws:iam::792686863424:root"
                ]
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::429656490274:root",
                    "arn:aws:iam::792686863424:root"
                ]
            },
            "Action": [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
            "Resource": "*"
        }
    ]
}
KMS_BUILD__KEY_POLICY

}

resource "aws_kms_alias" "ami-build-key-alias" {
  name          = "alias/ami-build"
  target_key_id = aws_kms_key.ami-build-kms-key.key_id
}

