variable "aws_region" {
  type        = string
  description = "AWS region to provision resources in"
  default     = "us-east-1"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "app_port" {
  type        = number
  description = "Port on which the Flask application listens"
  default     = 5000
}

variable "backup_retention_days" {
  type        = number
  description = "Number of days to retain daily backups in AWS Backup"
  default     = 7
}
