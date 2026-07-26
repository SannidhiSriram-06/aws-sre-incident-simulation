# Tech Stack — IT Support Ticket Simulation

## In Scope (AWS Account: `<AWS_ACCOUNT_ID>`, Region: `us-east-1`)

### AWS Services & Resource Specs
- **EC2 Instance (Original)**: `i-03ea35ccf12929d50` (`t3.micro`, Amazon Linux 2023 AMI `ami-00adf8f2fe708c532`, Public IP `44.204.4.170`, Private IP `172.31.95.25`)
- **EC2 Instance (Restored)**: `i-01c2e9d892ba80ea2` (`t3.micro`, Private IP `172.31.92.37`)
- **Default VPC**: `vpc-0b55d78f23eca89b0` (Subnet `subnet-0941950b9ebc5a474`, CIDR `172.31.0.0/16`)
- **Security Groups**: `sg-0a20a185f6897c2b0` (`flask-app-security-group`, port 5000), `sg-0785477f66c538d50` (VPN target SG)
- **IAM Personas**:
  - `Sriram_Infra` (`arn:aws:iam::<AWS_ACCOUNT_ID>:user/Sriram_Infra`): Owner identity
  - `Sriram_support` (`arn:aws:iam::<AWS_ACCOUNT_ID>:user/Sriram_support`): Support analyst identity with scoped policy (`AmazonSSMManagedInstanceCore`, CloudWatch Logs read, AWS Backup restore, Client VPN)
- **AWS Systems Manager (SSM) — Session Manager**: Browser & CLI-based remote shell (`session-manager-plugin` 1.2.835.0)
- **AWS Client VPN**: Endpoint `cvpn-endpoint-0921242195c1d0f3e` (`10.100.0.0/22`), Easy-RSA PKI, ACM certificates (`server.clientvpn.local` `4c650e91-7777-46fc-b895-6977b077b6e8`, `client1.domain.tld` `937d8d75-7aaa-4aae-8f74-ac7bceea4625`), split-tunnel config (`client-final.ovpn`)
- **CloudWatch Logs & Insights**: Log group `/ec2/flask-app` with Amazon CloudWatch Agent shipping `/var/log/flask-app/access.log`. Query ID `c823d42c-7451-4183-b421-7df4eb610412`
- **AWS Backup**: Vault `flask-app-backup-vault`, Plan `flask-app-daily-backup-plan` (`83a98e84-fe48-4b4f-b2f0-384fc648c379`), Service Role `<BACKUP_SERVICE_ROLE_ARN>`, Backup Job `1d9cb51d-740c-4b80-84ac-0d886ed09426`, Recovery Point `ami-0462b005fd67d30cd`, Restore Job `fc4418eb-b4c1-4a6b-9ffe-f8c343805153`

### App / Code Layer
- Minimal Flask application running on EC2 via systemd (`/etc/systemd/system/flask-app.service`, PID 2224), listening on `0.0.0.0:5000` (`/opt/flask-app/app.py`), logging to `/var/log/flask-app/access.log`.

### Deliverables Layer
- Markdown files: [INC-001_network_outage.md](file:///Users/sannidhidurgapavansriram/Sriram/LPU/Placements/Eproductivity%20Software/Cloud%20Support%20Project/ticket_logs/INC-001_network_outage.md), [INC-002_data_recovery.md](file:///Users/sannidhidurgapavansriram/Sriram/LPU/Placements/Eproductivity%20Software/Cloud%20Support%20Project/ticket_logs/INC-002_data_recovery.md), [KB-001_network_diagnostics.md](file:///Users/sannidhidurgapavansriram/Sriram/LPU/Placements/Eproductivity%20Software/Cloud%20Support%20Project/kb_articles/KB-001_network_diagnostics.md), [KB-002_aws_backup_restore.md](file:///Users/sannidhidurgapavansriram/Sriram/LPU/Placements/Eproductivity%20Software/Cloud%20Support%20Project/kb_articles/KB-002_aws_backup_restore.md), [customer_communications.md](file:///Users/sannidhidurgapavansriram/Sriram/LPU/Placements/Eproductivity%20Software/Cloud%20Support%20Project/communications/customer_communications.md), [resume_highlights.md](file:///Users/sannidhidurgapavansriram/Sriram/LPU/Placements/Eproductivity%20Software/Cloud%20Support%20Project/docs/resume_highlights.md).

## Explicitly Out of Scope
- Custom VPC, subnets, NAT Gateway, route tables
- SSM Automation Documents / auto-remediation
- EventBridge scheduling
- Cross-account IAM roles
- Amazon RDS / SQL database engines
- Kubernetes, Docker, Helm, ArgoCD, Jenkins, GitHub Actions

## Tooling Used
- **AWS CLI**: 2.36.8
- **Homebrew**: 6.0.12
- **GitHub CLI**: 2.96.0 (authenticated as `SannidhiSriram-06`)
- **Easy-RSA**: 3.2.6_1
- **AWS VPN Client**: 5.4.2
