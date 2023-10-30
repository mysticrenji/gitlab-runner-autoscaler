output "vpc_security_group_ids"{
value = aws_security_group.sg
}

output "subnet_id"{
value = aws_subnet.subnet.id
}