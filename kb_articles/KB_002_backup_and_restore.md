# KB Article: Restoring EC2 Instances via AWS Backup

**Article ID:** KB-002  
**Target Architecture:** AWS Backup Vault (`flask-app-backup-vault`), AWS Backup Plan (`flask-app-daily-backup-plan`), EC2 Instances  
**Author:** Support Analyst (`Sriram_support`)  

---

## When to Use This Article
Use this guide when data loss or corruption occurs on an EC2 instance target by AWS Backup, and you need to restore from a completed recovery point.

---

## Step 1 — Locate the Recovery Point
List available recovery points in the AWS Backup Vault:
```bash
aws backup list-recovery-points-by-backup-vault \
  --backup-vault-name flask-app-backup-vault \
  --profile support-analyst
```
Verify that `"Status"` is `"COMPLETED"` and note the `RecoveryPointArn` (e.g., `arn:aws:ec2:us-east-1::image/ami-0462b005fd67d30cd`).

---

## Step 2 — Fetch Restore Metadata Requirements
EC2 restores require specific launch parameters (`SubnetId`, `SecurityGroupIds`, `InstanceType`, `IamInstanceProfileName`). Fetch the original metadata from the recovery point:
```bash
aws backup get-recovery-point-restore-metadata \
  --backup-vault-name flask-app-backup-vault \
  --recovery-point-arn "arn:aws:ec2:us-east-1::image/ami-0462b005fd67d30cd" \
  --profile support-analyst
```

---

## Step 3 — Initiate the AWS Backup Restore Job
Construct the `--metadata` JSON payload. **Critical Syntax Rule:** `SecurityGroupIds` must be formatted as an escaped JSON array string (`"[\"sg-0a20a185f6897c2b0\"]"`).

```bash
aws backup start-restore-job \
  --recovery-point-arn "arn:aws:ec2:us-east-1::image/ami-0462b005fd67d30cd" \
  --iam-role-arn <BACKUP_SERVICE_ROLE_ARN> \
  --resource-type EC2 \
  --metadata '{"SubnetId":"subnet-0941950b9ebc5a474","SecurityGroupIds":"[\"sg-0a20a185f6897c2b0\"]","InstanceType":"t3.micro","IamInstanceProfileName":"flask-ec2-instance-profile"}' \
  --profile support-analyst
```
*Output returns `RestoreJobId` (e.g., `fc4418eb-b4c1-4a6b-9ffe-f8c343805153`).*

---

## Step 4 — Poll Job Status & Get Restored Instance ARN
Track job completion:
```bash
aws backup describe-restore-job \
  --restore-job-id fc4418eb-b4c1-4a6b-9ffe-f8c343805153 \
  --profile support-analyst
```
Once `"Status"` reaches `"COMPLETED"`, record the `CreatedResourceArn` (e.g., `arn:aws:ec2:us-east-1:<AWS_ACCOUNT_ID>:instance/i-01c2e9d892ba80ea2`).

---

## Step 5 — Verify Data Directly Inside Restored Instance
Do **not** assume `COMPLETED` restore status means the missing data was captured. Log in to the new instance via SSM Session Manager:
```bash
aws ssm start-session --target i-01c2e9d892ba80ea2 --profile support-analyst
```
Check application files and data directories directly:
```bash
sh-5.2$ ls /opt/flask-app/
app.py
sh-5.2$ cat /opt/flask-app/customer_data.txt 2>/dev/null || echo "FILE NOT FOUND"
```

---

## Operational Gotchas & Lessons Learned

1. **Required IAM Permissions for Support Persona:**
   The initiating IAM role/user must have permissions for `backup:StartRestoreJob`, `backup:GetRecoveryPointRestoreMetadata`, and `iam:PassRole` on the backup service role `<BACKUP_SERVICE_ROLE_ARN>`.
2. **Metadata Escaping:** Failing to double-escape `SecurityGroupIds` inside the metadata string will result in error `Restore metadata is invalid.` (Job `8e520334-00a4-499f-933b-eeea881048bb`).
3. **Backup Snapshot Window Gap:** AMI-based EC2 backups snapshot disk volumes at the moment of registration. Data written seconds before manual backup execution may not be captured in the recovery point. Direct instance verification is mandatory.
