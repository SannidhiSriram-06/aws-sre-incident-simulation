# IAM Role for EC2 Instance (SSM Session Manager + CloudWatch Agent)
resource "aws_iam_role" "ec2_role" {
  name = "flask-ec2-ssm-cw-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "flask-ec2-ssm-cw-role"
  }
}

# Attach AmazonSSMManagedInstanceCore policy for Session Manager access
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach CloudWatchAgentServerPolicy for shipping logs to CloudWatch Logs
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_server" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# IAM Instance Profile to attach to the EC2 instance
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "flask-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# IAM Role for AWS Backup Service
resource "aws_iam_role" "backup_role" {
  name = "aws-backup-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "aws-backup-service-role"
  }
}

resource "aws_iam_role_policy_attachment" "backup_service_policy" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "backup_restore_policy" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}
