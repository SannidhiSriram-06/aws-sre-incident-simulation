# IT Support Ticket Simulation

This project is a simulation of an AWS-based IT/Cloud Support Analyst workflow. It was built to demonstrate core support competencies for a Cloud Support Analyst role, focusing specifically on remote troubleshooting, VPN/network diagnostics, backup/restore operations, log-based root cause analysis, and customer communication. The environment was provisioned via IaC for setup speed, allowing the primary focus to remain entirely on hands-on support analyst operations and documentation.

## Support Tickets Executed

### Ticket #001 — Service Unreachable (Network vs. App Health)
A simulated customer reported their application was completely unresponsive externally. By using AWS Systems Manager (SSM) Session Manager for internal access and querying CloudWatch Logs Insights, the issue was isolated purely to a misconfigured Security Group network rule rather than an application crash. The ingress rule was re-authorized, restoring full service.

### Ticket #002 — Missing Data Recovery
A critical customer data record was deleted, requiring a restore from AWS Backup. A manual restore job was executed to spin up a new EC2 instance from a recent recovery point. Direct inspection of the restored instance confirmed successful recovery of the server state, while also revealing a valuable lesson about block snapshot timing and data consistency.

## Tools and Services Used
- **Compute & Networking:** AWS EC2 (Amazon Linux 2023), AWS Default VPC, Security Groups
- **Remote Access:** AWS Systems Manager (SSM) Session Manager, AWS Client VPN (Mutual TLS)
- **Observability:** Amazon CloudWatch Logs Insights, CloudWatch Agent
- **Data Protection:** AWS Backup (Vaults, Plans, Recovery Points, On-Demand Restores)
- **Security:** AWS IAM (Strict Least-Privilege Scoped Policies)

## Project Documentation

- **Ticket Logs:**
  - [Ticket #001: App Unreachable](ticket_logs/INC-001_network_outage.md)
  - [Ticket #002: Customer Data Missing](ticket_logs/INC-002_data_recovery.md)
- **Knowledge Base Articles:**
  - [KB-001: Diagnosing "Application Down" Reports](kb_articles/KB-001_network_diagnostics.md)
  - [KB-002: Restoring EC2 Instances via AWS Backup](kb_articles/KB-002_aws_backup_restore.md)
- **Customer Communications:**
  - [Customer Communication Samples](customer_communications.md)
- **Architecture & Setup:**
  - [Tech Stack Details](docs/technical_architecture.md)
  - [Project Requirements (PRD)](docs/requirements_and_goals.md)
  - [Project Definition](docs/project_overview.md)

## Lessons Learned & Next Steps

The most significant operational learning from this simulation came during the data recovery ticket. While the AWS Backup restore job completed successfully (reporting `COMPLETED` status), direct validation inside the newly restored instance revealed that a file written seconds before the backup was triggered did not persist in the snapshot. This reinforced a critical real-world support lesson: never trust a "success" status blind. A snapshot captures block storage state at the exact moment of registration, meaning point-in-time consistency requires direct, empirical validation by the support analyst before communicating recovery to a customer.
