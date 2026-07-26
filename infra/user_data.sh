#!/bin/bash
set -euo pipefail

# Log script output for debugging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Starting user_data execution..."

# Update system packages
dnf update -y

# Install Python 3, pip, and CloudWatch Agent on Amazon Linux 2023
dnf install -y python3 python3-pip amazon-cloudwatch-agent

# Install Flask
pip3 install flask

# Create application and logging directories
mkdir -p /opt/flask-app
mkdir -p /var/log/flask-app
chmod 755 /var/log/flask-app

# Create Flask application code
cat << 'EOF' > /opt/flask-app/app.py
import logging
from flask import Flask, request

app = Flask(__name__)

# Configure logging to file
log_file = "/var/log/flask-app/access.log"
logging.basicConfig(
    filename=log_file,
    level=logging.INFO,
    format='%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'
)

@app.before_request
def log_request_info():
    app.logger.info("Request: %s %s from %s", request.method, request.url, request.remote_addr)

@app.route('/')
def home():
    app.logger.info("Handling GET request on / - returning OK")
    return "OK\n", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

# Create Systemd service for Flask app
cat << 'EOF' > /etc/systemd/system/flask-app.service
[Unit]
Description=Minimal Flask Application
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/flask-app
ExecStart=/usr/bin/python3 /opt/flask-app/app.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Enable and start Flask application
systemctl daemon-reload
systemctl enable flask-app.service
systemctl start flask-app.service

# Configure CloudWatch Agent to collect Flask access logs
cat << 'EOF' > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "agent": {
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/flask-app/access.log",
            "log_group_name": "/ec2/flask-app",
            "log_stream_name": "{instance_id}",
            "timestamp_format": "%Y-%m-%d %H:%M:%S"
          }
        ]
      }
    }
  }
}
EOF

# Start CloudWatch Agent with configuration
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s

echo "user_data execution completed successfully."
