output "instance_id" {
  description = "ID of the provisioned EC2 instance"
  value       = aws_instance.flask_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.flask_server.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.flask_server.private_ip
}

output "security_group_id" {
  description = "ID of the Security Group"
  value       = aws_security_group.flask_sg.id
}

output "cloudwatch_log_group" {
  description = "Name of the CloudWatch Log Group shipping Flask logs"
  value       = aws_cloudwatch_log_group.flask_log_group.name
}

output "backup_vault_name" {
  description = "Name of the AWS Backup Vault"
  value       = aws_backup_vault.flask_backup_vault.name
}

output "backup_plan_id" {
  description = "ID of the AWS Backup Plan"
  value       = aws_backup_plan.flask_backup_plan.id
}

output "app_url" {
  description = "URL to access the Flask application"
  value       = "http://${aws_instance.flask_server.public_ip}:${var.app_port}/"
}
