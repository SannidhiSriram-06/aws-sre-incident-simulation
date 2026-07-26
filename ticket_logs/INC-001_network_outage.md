# Ticket #001 — App Unreachable

**Reported by:** Customer (simulated)  
**Reported symptom:** "The application is down — I can't reach it."  
**Severity:** High (customer-facing outage)  
**AWS Account ID:** `<AWS_ACCOUNT_ID>` (us-east-1)  
**Target Resource:** EC2 Instance `i-03ea35ccf12929d50` (`t3.micro`, Amazon Linux 2023, Public IP: `44.204.4.170`, Private IP: `172.31.95.25`)  
**IAM Personas:** Owner (`Sriram_Infra`) | Support Analyst (`Sriram_support`)  
**Accessed via:** AWS Systems Manager Session Manager (Session ID: `Sriram_support-eqllbg3fdtu3qe6xccj3b2xcce`)  

---

## Timeline

| Time (UTC / IST) | Action / Terminal Output | Persona |
|---|---|---|
| 11:15 UTC / 16:45 IST | Environment provisioned and verified healthy pre-incident: `curl http://44.204.4.170:5000/` -> `OK` | `Sriram_Infra` |
| 11:20 UTC / 16:50 IST | Pre-incident health check via SSM Session Manager: confirmed app process PID 2224 active (`systemctl status flask-app`) | `Sriram_support` |
| 11:30 UTC / 17:00 IST | Simulated outage: User A revoked Security Group `sg-0a20a185f6897c2b0` ingress rule for TCP/5000 (`sgr-00acf71bdfc1021cc`) | `Sriram_Infra` |
| 11:32 UTC / 17:02 IST | Outage confirmed externally: `curl --max-time 5 http://44.204.4.170:5000/` -> `curl: (28) Connection timed out after 5005 milliseconds` | `Sriram_support` |
| 11:35 UTC / 17:05 IST | Initiated SSM diagnostic session: `aws ssm start-session --target i-03ea35ccf12929d50 --profile support-analyst`. Verified app locally inside EC2: `curl http://localhost:5000/` -> `OK` | `Sriram_support` |
| 11:43 UTC / 17:13 IST | Queried CloudWatch Logs Insights on `/ec2/flask-app` (Query ID: `c823d42c-7451-4183-b421-7df4eb610412`). Confirmed ongoing `200` responses on `/` throughout incident | `Sriram_support` |
| 11:45 UTC / 17:15 IST | Identified root cause: Application healthy; fault isolated strictly to Security Group network ingress rule | `Sriram_support` |
| 11:46 UTC / 17:16 IST | Re-authorized SG ingress rule: `aws ec2 authorize-security-group-ingress --group-id sg-0a20a185f6897c2b0 --protocol tcp --port 5000 --cidr 0.0.0.0/0` (Rule ID: `sgr-045acc6ef1b69eb12`) | `Sriram_support` |
| 11:47 UTC / 17:17 IST | Confirmed recovery externally: `curl http://44.204.4.170:5000/` -> `OK` | `Sriram_support` |

---

## Diagnostic Logic

The diagnostic approach isolated network failure from application health:
1. **External check failed**: `curl --max-time 5 http://44.204.4.170:5000/` timed out.
2. **Internal check succeeded**: Connecting via SSM Session Manager (`Sriram_support-eqllbg3fdtu3qe6xccj3b2xcce`) allowed running `curl http://localhost:5000/` inside the server, which returned `OK`.
3. **Log confirmation**: CloudWatch Logs Insights query proved the application was handling requests continuously without throwing errors.
4. **Conclusion**: The fault was 100% network-layer (Security Group missing port 5000 ingress), ruling out application code bugs, service crashes, or server resource exhaustion.

---

## Root Cause

Security Group `flask-app-security-group` (`sg-0a20a185f6897c2b0`) in VPC `vpc-0b55d78f23eca89b0` had its ingress rule for TCP/5000 revoked, blocking external HTTP traffic to the Flask application while the underlying process remained healthy.

---

## Resolution Command & Output

```bash
aws ec2 authorize-security-group-ingress \
  --group-id sg-0a20a185f6897c2b0 \
  --protocol tcp \
  --port 5000 \
  --cidr 0.0.0.0/0
```

**Response Output:**
```json
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-045acc6ef1b69eb12",
            "GroupId": "sg-0a20a185f6897c2b0",
            "GroupOwnerId": "<AWS_ACCOUNT_ID>",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 5000,
            "ToPort": 5000,
            "CidrIpv4": "0.0.0.0/0",
            "SecurityGroupRuleArn": "arn:aws:ec2:us-east-1:<AWS_ACCOUNT_ID>:security-group-rule/sgr-045acc6ef1b69eb12"
        }
    ]
}
```

---

## Time to Resolve

~9 minutes from initial outage confirmation to verified resolution.

---

## Empirical Evidence

### CloudWatch Logs Insights Query Output
Log Group: `/ec2/flask-app`  
Query ID: `c823d42c-7451-4183-b421-7df4eb610412`

```json
{
    "results": [
        [
            { "field": "@timestamp", "value": "2026-07-26 11:43:35.000" },
            { "field": "@message", "value": "2026-07-26 11:43:35,780 INFO: Request: GET http://localhost:5000/ from 127.0.0.1 [in /opt/flask-app/app.py:16]" }
        ],
        [
            { "field": "@timestamp", "value": "2026-07-26 11:43:35.000" },
            { "field": "@message", "value": "2026-07-26 11:43:35,780 INFO: Handling GET request on / - returning OK [in /opt/flask-app/app.py:20]" }
        ]
    ]
}
```
