
data "aws_iam_policy" "aws_cloudwatch_agent_policy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "aws_sns_topic" "alarm_notification" {
  name = "bc-alerts-email"
}

resource "aws_iam_role" "jenkins_ec2_role" {
  name = "JenkinsEC2Role"

  assume_role_policy = <<JENKINS_ROLE_EOF
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
JENKINS_ROLE_EOF
}

resource "aws_iam_role_policy_attachment" "jenkins_role_attach_cloudwatch" {
  role       = aws_iam_role.jenkins_ec2_role.name
  policy_arn = data.aws_iam_policy.aws_cloudwatch_agent_policy.arn
}

resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  name = "jenkins-instance-profile"
  role = aws_iam_role.jenkins_ec2_role.name
}

module "ec2_cluster" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.17.0"

  name = var.jenkins_name
  instance_count = var.instance_count
  monitoring = false
  ami = var.ami_id
  instance_type = var.ec2_instance_type
  key_name = var.ssh_key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  cpu_credits = var.cpu_credits
  ebs_optimized = var.ebs_optimized
  subnet_ids = var.subnet_ids
  iam_instance_profile = aws_iam_instance_profile.jenkins_instance_profile.name

  root_block_device = [
    {
      volume_size = "1024"
      volume_type = "gp2"
    },
  ]

  user_data = <<JENKINS_DATA
#cloud-config
repo_update: false
repo_upgrade: none

JENKINS_DATA

  tags = {
      Name = var.jenkins_tag_name
      Environment = var.jenkins_tag_environment
      Owner = var.jenkins_tag_owner
    }
}

resource "aws_cloudwatch_metric_alarm" "mem_percent_used_alarm" {
  count = length(module.ec2_cluster.id)
  alarm_name = "JenkinsAlarmMemUsedInPercent-${module.ec2_cluster.id[count.index]}"
  alarm_description = "Alarm when memory used is over 95%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  threshold = "95"
  metric_name = "mem_used_percent"
  namespace = "CWAgent"
  statistic = "Average"
  period = "300"

  dimensions = {
    InstanceId = "${module.ec2_cluster.id[count.index]}"
  }

  alarm_actions = [data.aws_sns_topic.alarm_notification.arn]
  tags = {
    Environment = var.jenkins_tag_environment
    Name = var.jenkins_tag_name
    Owner = "BC"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_credit_balance_alarm" {
  count = length(module.ec2_cluster.id)
  alarm_name = "JenkinsAlarmCPUCredBalance-${module.ec2_cluster.id[count.index]}"
  alarm_description = "Alarm when ebs_credit_balance less than 10"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  threshold = "10"
  metric_name = "CPUCreditBalance"
  namespace = "AWS/EC2"
  statistic = "Average"
  period = "300"

dimensions = {
  InstanceId = "${module.ec2_cluster.id[count.index]}"
}

  alarm_actions = [data.aws_sns_topic.alarm_notification.arn]
  tags = {
    Environment = var.jenkins_tag_environment
    Name = var.jenkins_tag_name
    Owner = "BC"
  }
}

resource "aws_cloudwatch_metric_alarm" "root_percent_used_alarm" {
  alarm_name = "JenkinsAlarmRootDiskUsed"
  alarm_description = "Alarm when filsystem is over 100G used"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  threshold = "100000000000"
  metric_name = "disk_used"
  namespace = "CWAgent"
  statistic = "Maximum"
  period = "300"

  alarm_actions = [data.aws_sns_topic.alarm_notification.arn]
  tags = {
    Environment = var.jenkins_tag_environment
    Name = var.jenkins_tag_name
    Owner = "BC"
  }
}
