# PRD — IT Support Ticket Simulation

## Problem Statement
Sriram's current CV/portfolio is built entirely around DevOps/Cloud infra projects (Terraform, CI/CD, self-healing systems). The EProductivity Software Customer Support Intern JD wants evidence of remote troubleshooting, VPN/network familiarity, backup/restore operations, log-based diagnosis, and customer communication skills. This project demonstrates those skills using AWS Account `<AWS_ACCOUNT_ID>` (us-east-1).

## Goals
- **G1**: Demonstrate hands-on use of AWS remote-access tooling (SSM Session Manager, AWS Client VPN `cvpn-endpoint-0921242195c1d0f3e`) — maps to JD's "remote methods using VPNs... Remote Graphical Application"
- **G2**: Demonstrate log-based fault diagnosis using CloudWatch Logs Insights (`/ec2/flask-app`) — maps to "Diagnosing and repairing faults," "Troubleshooting technical issues"
- **G3**: Demonstrate backup/restore operations using AWS Backup (`flask-app-backup-vault`, Recovery Point `ami-0462b005fd67d30cd`, Restore Job `fc4418eb-b4c1-4a6b-9ffe-f8c343805153`) — maps to "Archiving/Restoring Site Backups onto central storage"
- **G4**: Produce actual Knowledge Base articles (KB-001, KB-002) — maps to "Creation of knowledge articles to share best practice"
- **G5**: Demonstrate customer communication ability — maps to "courtesy, tact and discretion," "High level customer service skills," "Speaking to customers"
- **G6**: Demonstrate IAM least-privilege understanding (2-user setup: `Sriram_Infra` owner vs. `Sriram_support` support analyst)

## Non-Goals
- **NG1**: Not meant to demonstrate infra-as-code depth — Terraform was used solely for environment bootstrap by User A (`Sriram_Infra`)
- **NG2**: Not attempting MS SQL DB administration
- **NG3**: Not attempting automation/self-healing (SSM Automation documents, EventBridge triggers)
- **NG4**: Not attempting cross-account IAM roles

## Success Criteria
- Both tickets fully broken and fully fixed on live EC2 instances (`i-03ea35ccf12929d50` and restored `i-01c2e9d892ba80ea2`)
- Ticket 1 diagnosed using actual CloudWatch Logs Insights query ID `c823d42c-7451-4183-b421-7df4eb610412`
- Backup restore executed end-to-end and inspected via SSM Session Manager
- AWS Client VPN provisioned with Easy-RSA certificates and tested via private IP (`http://172.31.95.25:5000/`)
- KB articles, ticket logs, and customer communications accurately mirror actual terminal execution

## User Stories (in-character, `Sriram_support` persona)
- As a support analyst, I receive a ticket reporting the app is unreachable, so I can investigate via SSM Session Manager and CloudWatch Logs Insights to isolate a Security Group rule blockage.
- As a support analyst, I want to restore lost customer data from AWS Backup, so I can verify whether snapshot points capture recent file writes.
- As a support analyst, I want to write a Knowledge Base article after resolving an issue, so team members can resolve similar incidents faster.
- As a support analyst, I want to send the customer a clear, non-technical status update, keeping them informed without confusing jargon.
