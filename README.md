# Cloud Support Engineering & Customer Support Simulation

This project is a hands-on simulation of an AWS-based Customer Support Analyst / Cloud Support Engineering workflow. Built to directly align with enterprise support requirements, the focus of this environment is providing proactive, empathetic, and highly technical support for software and cloud applications. The simulation validates core competencies including **remote fault diagnosis via VPNs**, **log file analysis**, **backup/restore operations**, **customer communication**, and **knowledge base (KB) article creation**.

## Core Competencies Demonstrated

* **Remote Issue Resolution & VPNs:** Configured and utilized AWS Client VPN (Mutual TLS) and Systems Manager (SSM) Session Manager to securely access remote servers and diagnose faults internally.
* **Fault Diagnosis & Log Analysis:** Queried and interpreted application logs using Amazon CloudWatch Logs Insights to isolate complex network configuration issues from application-level failures.
* **Archiving & Restoring Data:** Executed point-in-time recovery using AWS Backup, restoring corrupted/missing customer data onto replacement EC2 instances and verifying state integrity.
* **Technical Documentation & KBs:** Translated complex technical findings into usable site manuals and Knowledge Base articles to share best practices across the support team.
* **Customer-Facing Communication:** Drafted empathetic, non-jargon status updates to keep external customers informed during service disruptions, demonstrating tact and excellent interpersonal skills.

## Operational Scenarios Executed

### Scenario 01: Service Unreachable (Network vs. Application Health)
A simulated customer reported their application was completely unresponsive externally. By using SSM Session Manager for secure remote access and querying CloudWatch Logs Insights, the issue was rapidly isolated to a misconfigured Security Group network rule rather than a server crash. The ingress rule was re-configured and verified, restoring full service with minimal downtime.

### Scenario 02: Missing Customer Data Recovery
A critical customer data record was deleted, requiring rapid response. A manual restore job was executed via AWS Backup to recover a recent recovery point onto a new instance. Direct inspection of the restored environment confirmed successful recovery, while reinforcing a critical lesson on backup timing and data consistency.

## Tools and Services Used
- **Remote Access & Networking:** AWS Client VPN (Mutual TLS), AWS Systems Manager (SSM) Session Manager, AWS Default VPC, Security Groups
- **Observability:** Amazon CloudWatch Logs Insights, CloudWatch Agent
- **Data Protection:** AWS Backup (Vaults, Plans, Recovery Points, On-Demand Restores)
- **Compute:** AWS EC2 (Amazon Linux 2023)
- **Security:** AWS IAM (Strict Least-Privilege Scoped Policies)

## Visual Evidence & Screenshots

To validate the hands-on execution of these tasks, **over 50 screenshots** capturing terminal commands, AWS Console configurations, VPN connections, log queries, and backup operations have been documented in the repository.
- [View Visual Evidence (`screenshots/`)](screenshots/)

## Project Documentation

- **Incident Reports:**
  - [INC-001: App Unreachable](ticket_logs/INC-001_network_outage.md)
  - [INC-002: Customer Data Missing](ticket_logs/INC-002_data_recovery.md)
- **Knowledge Base Articles:**
  - [KB-001: Diagnosing "Application Down" Reports](kb_articles/KB-001_network_diagnostics.md)
  - [KB-002: Restoring EC2 Instances via AWS Backup](kb_articles/KB-002_aws_backup_restore.md)
- **Customer Communications:**
  - [Customer Communication Samples](communications/customer_communications.md)
- **Architecture & Setup:**
  - [Tech Stack Details](docs/technical_architecture.md)
  - [Project Requirements (PRD)](docs/requirements_and_goals.md)
  - [Project Definition](docs/project_overview.md)

## Lessons Learned & Best Practices

The most significant operational learning from this simulation came during the data recovery scenario. While the AWS Backup restore job completed successfully (reporting `COMPLETED` status), direct validation inside the newly restored instance revealed that a file written seconds before the backup was triggered did not persist in the snapshot. This reinforced a critical real-world support lesson: never trust a "success" status blind. A snapshot captures block storage state at the exact moment of registration, meaning point-in-time consistency requires direct, empirical validation by the support analyst before communicating recovery to a customer.
