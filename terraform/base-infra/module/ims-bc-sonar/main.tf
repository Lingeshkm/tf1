data "aws_iam_policy" "aws_ssm_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

data "aws_iam_policy" "aws_cloudwatch_agent_policy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "aws_sns_topic" "alarm_notification" {
  name = "bc-alerts-email"
}

resource "aws_iam_policy" "sonarqube_custom_policy" {
    name        = "SonarQubePolicy"
    path        = "/ims-bc/"
    description = "The allowed actions that an EC2 machine running SonarQube can perform"

    policy = <<SONAR_CUSTOM_POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:DescribeSecret",
                "secretsmanager:List*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": [
                "arn:aws:secretsmanager:*:*:secret:/base_infra/on-prem/ldapauth-??????",
                "arn:aws:secretsmanager:*:*:secret:/base_infra/*/pg_sonarqube_readwrite-??????",
                "arn:aws:secretsmanager:*:*:secret:/base_infra/*/rds_admin_pw-??????"
            ]
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "ssm:GetParametersByPath",
                "ssm:GetParameters",
                "ssm:GetParameter"
            ],
            "Resource": [
                "arn:aws:ssm:*:*:parameter/default_env",
                "arn:aws:ssm:*:*:parameter/base_infra/*/rnd_bcdb_fqdn"
            ]
        },
        {
            "Sid": "VisualEditor3",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:PutObjectVersionTagging",
                "s3:PutObjectTagging"
            ],
            "Resource": "arn:aws:s3:::ims-bc-backup-prod/sonarqube/*"
        },
        {
            "Sid": "VisualEditor4",
            "Effect": "Allow",
            "Action": [
                "autoscaling:SuspendProcesses",
                "autoscaling:ResumeProcesses"
            ],
            "Resource": "arn:aws:autoscaling:*:*:autoScalingGroup:*:autoScalingGroupName/${var.sonar_asg_name}-*"
        },
        {
            "Sid": "VisualEditor5",
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingInstances"
            ],
            "Resource": "*"
        }
    ]
}
SONAR_CUSTOM_POLICY
}

resource "aws_iam_role" "sonarqube_ec2_role" {
  name = "SonarQubeEC2Role"

  assume_role_policy = <<SONAR_ROLE_EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
SONAR_ROLE_EOF
}

resource "aws_iam_role_policy_attachment" "sonar_role_attach_ssm" {
  role       = aws_iam_role.sonarqube_ec2_role.name
  policy_arn = data.aws_iam_policy.aws_ssm_policy.arn
}

resource "aws_iam_role_policy_attachment" "sonar_role_attach_cloudwatch" {
  role       = aws_iam_role.sonarqube_ec2_role.name
  policy_arn = data.aws_iam_policy.aws_cloudwatch_agent_policy.arn
}

resource "aws_iam_role_policy_attachment" "sonar_role_attach_secrets_manager" {
  role       = aws_iam_role.sonarqube_ec2_role.name
  policy_arn = aws_iam_policy.sonarqube_custom_policy.arn
}

resource "aws_iam_instance_profile" "sonar_instance_profile" {
  name = "sonarqube_instance_profile"
  role = aws_iam_role.sonarqube_ec2_role.name
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "3.4.0"

  name = var.sonar_tag_name
  lc_name = var.launch_conf_name
  image_id = var.ami_id
  instance_type = var.ec2_instance_type
  security_groups = var.sonar_sg
  target_group_arns = var.sonar_lb_id
  service_linked_role_arn = var.amibuild_service_linked_role_arn
  iam_instance_profile = aws_iam_instance_profile.sonar_instance_profile.arn

  root_block_device = [
    {
      volume_size = "8"
      volume_type = "gp2"
    },
  ]

  asg_name = var.sonar_asg_name
  vpc_zone_identifier = var.sonar_asg_subnets
  health_check_type = "ELB"
  min_size = 1
  max_size = 1
  desired_capacity = 1
  wait_for_capacity_timeout = "10m"
  user_data = <<SONAR_DATA
#cloud-config
repo_update: false
repo_upgrade: none

runcmd:
- file_system_id_01=${var.sonar_efs_id}
- efs_directory=/data

- mkdir -p $${efs_directory}
- echo "$${file_system_id_01}:/ $${efs_directory} efs tls,_netdev" >> /etc/fstab
- mount -a -t efs defaults
- /usr/bin/sonar-fetch-passwords
- docker-compose -f /etc/docker-services/docker-compose.yml up -d
SONAR_DATA

  tags = [
    {
      key = "Environment"
      value = var.sonar_tag_environment
      propagate_at_launch = true
    },
    {
      key = "Owner"
      value = var.sonar_tag_owner
      propagate_at_launch = true
    }
  ]
}


resource "aws_cloudwatch_metric_alarm" "mem_percent_used_alarm" {
  alarm_name = "SonarQubeAlarmMemUsedInPercent"
  alarm_description = "Alarm when memory used is over 95%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  threshold = "95"
  metric_name = "mem_used_percent"
  namespace = "CWAgent"
  statistic = "Average"
  period = "300"

  dimensions = {
    AutoScalingGroupName = module.autoscaling.this_autoscaling_group_name
  }
  alarm_actions = [data.aws_sns_topic.alarm_notification.arn]
  tags = {
    Environment = var.sonar_tag_environment
    Name = var.sonar_tag_name
    Owner = "BC"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_credit_balance_alarm" {
  alarm_name = "SonarQubeAlarmCPUCredBalance"
  alarm_description = "Alarm when ebs_credit_balance less than 10"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  threshold = "10"
  metric_name = "CPUCreditBalance"
  namespace = "AWS/EC2"
  statistic = "Average"
  period = "300"

  dimensions = {
    AutoScalingGroupName = module.autoscaling.this_autoscaling_group_name
  }
  alarm_actions = [data.aws_sns_topic.alarm_notification.arn]
  tags = {
    Environment = var.sonar_tag_environment
    Name = var.sonar_tag_name
    Owner = "BC"
  }
}

resource "aws_cloudwatch_metric_alarm" "efs_percent_used_alarm" {
  alarm_name = "SonarQubeAlarmEFSDiskUsed"
  alarm_description = "Alarm when efs is over 10G used "
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  threshold = "50000000000"
  metric_name = "disk_used"
  namespace = "CWAgent"
  statistic = "Maximum"
  period = "300"

  dimensions = {
    AutoScalingGroupName = module.autoscaling.this_autoscaling_group_name
    device = "127.0.0.1:/"
    fstype = "nfs4"
    path = "/data"
  }
  alarm_actions = [data.aws_sns_topic.alarm_notification.arn]
  tags = {
    Environment = var.sonar_tag_environment
    Name = var.sonar_tag_name
    Owner = "BC"
  }
}
