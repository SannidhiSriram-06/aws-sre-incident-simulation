# AWS Backup Vault
resource "aws_backup_vault" "flask_backup_vault" {
  name        = "flask-app-backup-vault"
  kms_key_arn = null # Uses default AWS Backup KMS key

  tags = {
    Name = "flask-app-backup-vault"
  }
}

# AWS Backup Plan
resource "aws_backup_plan" "flask_backup_plan" {
  name = "flask-app-daily-backup-plan"

  rule {
    rule_name         = "daily-backup-rule"
    target_vault_name = aws_backup_vault.flask_backup_vault.name
    schedule          = "cron(0 12 * * ? *)" # Daily backup at 12:00 UTC

    lifecycle {
      delete_after = var.backup_retention_days # Retain for 7 days
    }
  }

  tags = {
    Name = "flask-app-daily-backup-plan"
  }
}

# AWS Backup Selection targeting the EC2 instance
resource "aws_backup_selection" "flask_ec2_backup_selection" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = "flask-app-ec2-selection"
  plan_id      = aws_backup_plan.flask_backup_plan.id

  resources = [
    aws_instance.flask_server.arn
  ]
}
