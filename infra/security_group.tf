# Query the Default VPC
data "aws_vpc" "default" {
  default = true
}

# Security Group for Flask App
resource "aws_security_group" "flask_sg" {
  name        = "flask-app-security-group"
  description = "Security Group for Flask app allowing inbound TCP 5000 and all outbound"
  vpc_id      = data.aws_vpc.default.id

  # Inbound rule for Flask app on port 5000
  ingress {
    description      = "Allow HTTP traffic on port 5000 for Flask application"
    from_port        = var.app_port
    to_port          = var.app_port
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Outbound rule for all traffic
  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "flask-app-sg"
  }
}
