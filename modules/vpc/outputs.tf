output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = ["${aws_subnet.public_subnet.*.id}"]
}

output "private_subnet_ids" {
  value = ["${aws_subnet.private_subnet.*.id}"]
}

output "thirdparty_subnet_ids" {
  value = ["${aws_subnet.thirdparty_subnet.*.id}"]
}

output "datacenter_subnet_ids" {
  value = ["${aws_subnet.datacenter_subnet.*.id}"]
}



#output "default_sg_id" {
#  value = "${aws_security_group.default.id}"
#}
#
output "public_security_groups" {
  value = ["${aws_security_group.public_vpc_sg.id}"]
}
output "private_security_groups" {
  value = ["${aws_security_group.private_vpc_sg.id}"]
}
output "database_security_groups" {
  value = ["${aws_security_group.database_sg.id}"]
}
output "jumpbox_security_groups" {
  value = ["${aws_security_group.jumpbox_sg.id}"]
}
output "alb_security_groups" {
  value = ["${aws_security_group.public_alb_sg.id}"]
}

output "public_route_table" {
  value = aws_route_table.public_subnet_rtb[*].id
}

output "private_route_tables" {
  value = aws_route_table.private_subnet_rtb[*].id
}

output "nat_gateway_ips" {
  value = aws_eip.nat_eip[*].public_ip
}

output "ec2_jumpbox_id" {
  value = aws_instance.jumpbox.id
}
