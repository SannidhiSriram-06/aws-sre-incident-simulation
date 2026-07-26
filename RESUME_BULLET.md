# Resume Bullet — IT Support Ticket Simulation

## Recommended version (for this JD / support-analyst framing)

**IT Support Ticket Simulation** | AWS SSM, Client VPN, CloudWatch Logs Insights, AWS Backup | GitHub | Jul 2026
- Simulated a scoped-access support engagement using two IAM identities (`Sriram_Infra` owner, `Sriram_support` support analyst) — resolving 2 simulated incidents (service outage, data-loss recovery) via remote access (SSM Session Manager, AWS Client VPN `cvpn-endpoint-0921242195c1d0f3e`) without SSH keys or standing admin access.
- Diagnosed a simulated outage on an Amazon Linux 2023 EC2 instance (`i-03ea35ccf12929d50`) by isolating a port 5000 Security Group rule blockage (`sg-0a20a185f6897c2b0`) from application health using CloudWatch Logs Insights (`/ec2/flask-app`) and internal-vs-external reachability checks.
- Executed an AWS Backup EC2 restore end-to-end (`flask-app-backup-vault`, AMI `ami-0462b005fd67d30cd`), surfacing and documenting a real point-in-time snapshot consistency gap on restored instance (`i-01c2e9d892ba80ea2`) via direct inspection rather than trusting job status alone.
- Produced incident ticket logs (#001, #002), knowledge base articles (KB-001, KB-002), and customer-facing status updates, mirroring real cloud support-analyst deliverables.

---

## Shorter single-bullet version (if space-constrained)
**IT Support Ticket Simulation** — Diagnosed and resolved 2 simulated incidents (Security Group network outage, AWS Backup data-loss recovery) on AWS via SSM Session Manager and Client VPN using CloudWatch Logs Insights for root-cause isolation and AWS Backup for restore validation; documented findings as ticket logs, KB articles, and customer-facing communications.

---

## Notes on scope & Interview Alignment
- **Infrastructure Provisioning**: Initial infrastructure was set up by User A (`Sriram_Infra`) to create the default VPC environment, Security Group `sg-0a20a185f6897c2b0`, IAM roles, and AWS Backup plan (`83a98e84-fe48-4b4f-b2f0-384fc648c379`). All support troubleshooting (Ticket 1 & Ticket 2) was performed by User B (`Sriram_support`) using standard console/CLI/SSM tools.
- **VPN Verification**: Configured mutual certificate authentication (Easy-RSA PKI, ACM certificates `server.clientvpn.local` and `client1.domain.tld`), associated subnet `subnet-0941950b9ebc5a474`, exported OpenVPN configuration (`client-final.ovpn`), and verified direct private IP access (`http://172.31.95.25:5000/`) over AWS Client VPN.
- **Diagnostic Rigor**: The backup/restore ticket documents a real-world snapshot timing limitation rather than a clean success — demonstrating real diagnostic thinking during interview technical discussions.
