output "ELASTIC_IP" {
  value = "${aws_eip.jenkins-demo-master.public_ip}"
}

output "SUBNET_ID" {
  value = "${aws_subnet.jenkins-demo.id}"
}

output "SECURITY_GROUP_ID_SSH" {
  value = "${aws_security_group.jenkins-demo-ssh.id}"
}

output "SECURITY_GROUP_ID_HTTP" {
  value = "${aws_security_group.jenkins-demo-http.id}"
}

output "SECURITY_GROUP_ID_SLAVEPORT" {
  value = "${aws_security_group.jenkins-demo-slaveport.id}"
}

output "SECURITY_GROUP_ID_INTERNAL" {
  value = "${aws_security_group.jenkins-demo-internal.id}"
}

output "AWS_DEFAULT_REGION" {
  value = "${var.aws_default_region}"
}

output "DEMO_NAME" {
  value = "${var.demo_name}"
}
