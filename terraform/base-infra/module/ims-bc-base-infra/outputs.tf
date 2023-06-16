output "account_id" {
  value = "${data.aws_caller_identity.my_identity.account_id}"
}

output "caller_arn" {
  value = "${data.aws_caller_identity.my_identity.arn}"
}

output "caller_user" {
  value = "${data.aws_caller_identity.my_identity.user_id}"
}

output "vpc_subnets_app_2a_id" {
  value = "${aws_subnet.subnet_app_2a.id}"
}

output "vpc_subnets_app_2b_id" {
  value = "${aws_subnet.subnet_app_2b.id}"
}

output "vpc_subnets_lambda_2b_id" {
  value = "${aws_subnet.subnet_lambda_2b.id}"
}

output "vpc_subnets_lambda_2c_id" {
  value = "${aws_subnet.subnet_lambda_2c.id}"
}

output "vpc_subnets_rds_2a_id" {
  value = "${aws_subnet.subnet_rds_2a.id}"
}

output "vpc_subnets_rds_2b_id" {
  value = "${aws_subnet.subnet_rds_2b.id}"
}

output "vpc_subnets_elb_2a_id" {
  value = "${aws_subnet.subnet_elb_2a.id}"
}

output "vpc_subnets_elb_2b_id" {
  value = "${aws_subnet.subnet_elb_2b.id}"
}

output "vpc_subnets_build_2a_id" {
  value = "${aws_subnet.subnet_build_2a.id}"
}

output "vpc_subnets_build_2b_id" {
  value = "${aws_subnet.subnet_build_2b.id}"
}

output "vpc_id" {
  value = "${data.aws_vpc.vpc_id.id}"
}

output "all_outbound_sg_id" {
  value = "${aws_security_group.all_outbound_sg.id}"
}

output "jenkins-master_sg_id" {
  value = "${aws_security_group.jenkins-master_sg.id}"
}

output "jenkins-builder-rdp_sg_id" {
  value = "${aws_security_group.jenkins-builder-rdp_sg.id}"
}

output "jenkins-ci-master_key_id" {
  value = "${aws_key_pair.jenkins-ci-ssh-key.id}"
}
