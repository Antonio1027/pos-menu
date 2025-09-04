output "instance_public_ip" {
    value       = aws_instance.django_app_instance.public_ip
    description = "Public IP address of the EC2 instance"
}

output "app_security_group_id" {
    value       = var.create_security_group ? aws_security_group.django_sg[0].id : data.aws_security_group.existing_sg[0].id
}