# KB Article: Diagnosing "Application Down" Reports on AWS-Hosted Apps

**Article ID:** KB-001  
**Target Architecture:** EC2 (Amazon Linux 2023), Flask Application, CloudWatch Agent, Security Groups  
**Author:** Support Analyst (`Sriram_support`)  

---

## When to Use This Article
Use this guide when a customer reports an EC2-hosted application is unreachable or returning connection timeouts. Follow this systematic workflow to isolate network-layer blockages from application code failures.

---

## Step 1 — Confirm the Outage Externally
Test the public endpoint directly using `curl`:
```bash
curl --max-time 5 http://44.204.4.170:5000/
```
- **Result: `curl: (28) Connection timed out after 5005 milliseconds`** → Indicates traffic is blocked at the network perimeter (Security Group, NACL, or Route Table).
- **Result: `HTTP 500 / Internal Server Error`** → Indicates application code or service crash.

---

## Step 2 — Remote Access via SSM Session Manager
Do not rely on SSH (TCP/22) or open application ports to inspect the machine. Access the instance securely via AWS Systems Manager Session Manager:
```bash
aws ssm start-session --target i-03ea35ccf12929d50 --profile support-analyst
```
*Note: Requires `session-manager-plugin` installed on the workstation.*

---

## Step 3 — Internal Application Reachability & Service Check
Inside the SSM session (`sh-5.2$`), test application reachability over `localhost`:
```bash
curl http://localhost:5000/
# Expected Output: OK

sudo systemctl status flask-app
```
- **If `localhost:5000` returns `OK` while external access times out:** The application service is healthy. The issue is 100% network-layer.
- **If `localhost:5000` fails:** Check systemd logs (`journalctl -u flask-app -n 50`) for Python runtime exceptions.

---

## Step 4 — Query CloudWatch Logs Insights
To confirm application behavior during the outage window, run a CloudWatch Logs Insights query against `/ec2/flask-app`:
```bash
aws logs start-query \
  --log-group-name /ec2/flask-app \
  --start-time $(date -v-1H +%s) \
  --end-time $(date +%s) \
  --query-string 'fields @timestamp, @message | sort @timestamp desc | limit 20' \
  --profile support-analyst
```
Inspect results using `aws logs get-query-results --query-id <QUERY_ID>`.  
Continuous `200 OK` entries prove the server process processed requests without interruption throughout the outage window.

---

## Step 5 — Remediate Security Group Misconfiguration
If the Security Group rule was revoked or misconfigured, re-authorize ingress for TCP port 5000 on Security Group `sg-0a20a185f6897c2b0`:
```bash
aws ec2 authorize-security-group-ingress \
  --group-id sg-0a20a185f6897c2b0 \
  --protocol tcp \
  --port 5000 \
  --cidr 0.0.0.0/0
```

---

## Step 6 — Verify External Recovery
Re-run the external health check to confirm recovery:
```bash
curl http://44.204.4.170:5000/
# Output: OK
```

---

## Key Takeaway & Common Pitfall
Never assume a connection timeout means the application crashed. Always verify internal vs. external reachability first to avoid unnecessary service restarts or code troubleshooting when the issue is a missing firewall rule.
