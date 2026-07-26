# Data source to fetch the latest Amazon Linux 2023 AMI in us-east-1
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Fetch subnets in Default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# CloudWatch Log Group for Flask application logs shipped by CloudWatch Agent
resource "aws_cloudwatch_log_group" "flask_log_group" {
  name              = "/ec2/flask-app"
  retention_in_days = 7

  tags = {
    Name = "flask-app-log-group"
  }
}

# EC2 Instance
resource "aws_instance" "flask_server" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  subnet_id              = element(data.aws_subnets.default.ids, 0)
  vpc_security_group_ids = [aws_security_group.flask_sg.id]

  user_data                   = file("${path.module}/user_data.sh")
  user_data_replace_on_change = true

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "flask-app-instance"
  }

  depends_on = [
    aws_cloudwatch_log_group.flask_log_group
  ]
}
