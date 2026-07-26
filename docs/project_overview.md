# Project Definition — IT Support Ticket Simulation

## What This Project Is
A weekend-built simulation of an AWS-based IT/Customer Support Analyst workflow, built to demonstrate fit for the EProductivity Software — Customer Support Intern (Cloud Computing) role at LPU's placement drive (Drive Code TC.40181.2027.62599, deadline Jul 27 2026).

## What This Project Is NOT
- NOT an infrastructure/DevOps showcase project (no custom VPC — deliberately using AWS default VPC `vpc-0b55d78f23eca89b0`; Terraform/IaC was used under the hood by User A purely to save setup time, but is never mentioned, bragged about, or listed as a skill for this project — the resume bullet and KB docs describe only what User B did)
- NOT a coding-heavy project — minimal Flask app scaffolding (`/opt/flask-app/app.py`), written fresh for this project only
- NOT reusing any code, IaC, or resources from prior projects — built fresh in AWS account `<AWS_ACCOUNT_ID>` (us-east-1)

## Core Concept
Two IAM users simulate a real support engagement:
- **IAM User A ("Owner" / `Sriram_Infra`)** — created and owns all AWS resources (`i-03ea35ccf12929d50`, SG `sg-0a20a185f6897c2b0`, Backup Vault `flask-app-backup-vault`, Backup Plan `83a98e84-fe48-4b4f-b2f0-384fc648c379`), representing the customer/company whose environment has issues
- **IAM User B ("Support Analyst" / `Sriram_support`)** — has scoped, non-admin permissions (SSM Session Manager, CloudWatch Logs read, AWS Backup restore, Client VPN connect). Persona doing all actual support troubleshooting. User B never creates base infrastructure — only accesses, diagnoses, and fixes issues.

## Scenario
User B receives 2 simulated support tickets against an EC2-hosted app owned by User A, resolves both remotely (via SSM Session Manager and AWS Client VPN), and documents each resolution as a real support analyst would.

## The 2 Tickets
1. **Ticket #001 — "App is down"**: Security Group `sg-0a20a185f6897c2b0` misconfiguration revokes TCP/5000 ingress rule (`sgr-00acf71bdfc1021cc`) → diagnosed via SSM (`curl localhost:5000`) and CloudWatch Logs Insights (`/ec2/flask-app`, Query ID `c823d42c-7451-4183-b421-7df4eb610412`) → fixed by re-authorizing ingress rule (`sgr-045acc6ef1b69eb12`).
2. **Ticket #002 — "Data is gone"**: Data deleted (`/opt/flask-app/customer_data.txt`, Order #4471) → restored via AWS Backup (`BackupJobId` `1d9cb51d-740c-4b80-84ac-0d886ed09426`, Recovery Point `ami-0462b005fd67d30cd`, Restore Job `fc4418eb-b4c1-4a6b-9ffe-f8c343805153`) producing restored EC2 instance `i-01c2e9d892ba80ea2`.

## Verified Remote Access Paths
1. **SSM Session Manager**: Connected via `aws ssm start-session --target i-03ea35ccf12929d50 --profile support-analyst`. Tested scoped permissions (`create-access-key` returned `AccessDeniedException`).
2. **AWS Client VPN**: Created Client VPN endpoint `cvpn-endpoint-0921242195c1d0f3e` (`10.100.0.0/22`), associated subnet `subnet-0941950b9ebc5a474`, imported ACM certificates (`server.clientvpn.local` `4c650e91-7777-46fc-b895-6977b077b6e8`, `client1.domain.tld` `937d8d75-7aaa-4aae-8f74-ac7bceea4625`), authorized ingress `172.31.0.0/16`, and verified direct private IP access across VPN: `curl http://172.31.95.25:5000/` -> `OK`.

## Deliverables Checklist
1. IAM setup (User A `Sriram_Infra` + scoped User B `Sriram_support`)
2. Working EC2 app (default VPC `vpc-0b55d78f23eca89b0`, Amazon Linux 2023 `ami-00adf8f2fe708c532`)
3. SSM Session Manager access configured and verified
4. AWS Client VPN access configured and verified (`cvpn-endpoint-0921242195c1d0f3e`)
5. 2 resolved tickets with full break → diagnose → fix cycle
6. 2 ticket resolution logs ([INC-001_network_outage.md](file:///Users/sannidhidurgapavansriram/Sriram/LPU/Placements/Eproductivity%20Software/Cloud%20Support%20Project/ticket_logs/INC-001_network_outage.md), [INC-002_data_recovery.md](file:///Users/sannidhidurgapavansriram/Sriram/LPU/Placements/Eproductivity%20Software/Cloud%20Support%20Project/ticket_logs/INC-002_data_recovery.md))
7. 2 Knowledge Base articles ([KB-001_network_diagnostics.md](file:///Users/sannidhidurgapavansriram/Sriram/LPU/Placements/Eproductivity%20Software/Cloud%20Support%20Project/kb_articles/KB-001_network_diagnostics.md), [KB-002_aws_backup_restore.md](file:///Users/sannidhidurgapavansriram/Sriram/LPU/Placements/Eproductivity%20Software/Cloud%20Support%20Project/kb_articles/KB-002_aws_backup_restore.md))
8. 1 customer-facing status email sample ([customer_communications.md](file:///Users/sannidhidurgapavansriram/Sriram/LPU/Placements/Eproductivity%20Software/Cloud%20Support%20Project/communications/customer_communications.md))
9. 1 resume bullet ([resume_highlights.md](file:///Users/sannidhidurgapavansriram/Sriram/LPU/Placements/Eproductivity%20Software/Cloud%20Support%20Project/docs/resume_highlights.md))
