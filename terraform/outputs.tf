output "instance_ip" {
  value = aws_instance.ansible-pull-demo.*.public_ip
}

output "instance_dns" {
  value = aws_instance.ansible-pull-demo.*.public_dns
}
