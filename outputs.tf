
output "instance_id" {
  value = aws_instance.ubuntu_vm.id
}

output "public_ip" {
  value       = aws_instance.ubuntu_vm.public_ip
  description = "The public IP of the web server"
}

output "security_groups" {
  value = [aws_instance.ubuntu_vm.vpc_security_group_ids]
}
