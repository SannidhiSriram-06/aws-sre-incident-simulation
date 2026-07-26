# Customer Communication Sample

## Ticket #001 — Outage Resolution Email

**Subject:** Update on your reported issue — Service Unreachable on Port 5000 (Resolved)

Hi [Customer Name],

Thanks for flagging this, and sorry for the disruption to your service.

We identified the issue as a network security configuration rule on our side — not a problem with your application code or server health — and it is now fully resolved. Security group ingress rules for port 5000 have been re-authorized, and we have confirmed your application is responding normally with `200 OK` status.

We've also verified via CloudWatch Logs Insights that your application process remained healthy throughout the incident.

If you notice anything else unusual, please don't hesitate to reach out right away.

Thanks for your patience,  
**Sriram S.** | Cloud Support Analyst  

---

## Ticket #002 — Data Recovery Status Email

**Subject:** Update on your data recovery request — Order #4471 Record

Hi [Customer Name],

Thanks for your patience while we investigated the missing record (`/opt/flask-app/customer_data.txt`, Order #4471) you reported.

We initiated a complete EC2 restore job (`fc4418eb-b4c1-4a6b-9ffe-f8c343805153`) from our AWS Backup vault (`flask-app-backup-vault`) using recovery point AMI `ami-0462b005fd67d30cd`. The restored server (`i-01c2e9d892ba80ea2`) has been successfully provisioned and verified online.

While inspecting the restored instance directly via Systems Manager, we observed that while all core application files (`app.py`) are fully intact, the specific record created immediately prior to the backup window was not captured due to block snapshot timing. Rather than marking this resolved based solely on the backup job's `COMPLETED` status, we want to be completely transparent with you while we perform a secondary recovery check.

Everything else on your account is fully operational. We will follow up directly as soon as our secondary review completes.

Thanks for bearing with us,  
**Sriram S.** | Cloud Support Analyst  
