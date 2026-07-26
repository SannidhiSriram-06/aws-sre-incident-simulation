# Ticket #002 — Customer Data Missing & AWS Backup Restore

**Reported by:** Customer (simulated)  
**Reported symptom:** "A customer record (`/opt/flask-app/customer_data.txt`) has gone missing from the server."  
**Severity:** High (Data Loss)  
**AWS Account ID:** `<AWS_ACCOUNT_ID>` (us-east-1)  
**Target Resource:** EC2 Instance `i-03ea35ccf12929d50` (`t3.micro`, Amazon Linux 2023, Subnet `subnet-0941950b9ebc5a474`)  
**AWS Backup Vault:** `flask-app-backup-vault` | **Backup Plan ID:** `83a98e84-fe48-4b4f-b2f0-384fc648c379`  
**Backup Service Role:** `<BACKUP_SERVICE_ROLE_ARN>`  
**IAM Personas:** Owner (`Sriram_Infra`) | Support Analyst (`Sriram_support`)  
**Accessed via:** SSM Session Manager + AWS Backup CLI  

---

## Timeline

| Time (UTC / IST) | Action / Command Executed | Persona / Output |
|---|---|---|
| 12:00 UTC / 17:30 IST | Connected via SSM (`Sriram_support-b9oeyorkxodqgjgq6xnkljl7uu`). Created live customer data file: `echo "Customer record: Order #4471, Status: Confirmed, Date: 2026-07-26" \| sudo tee /opt/flask-app/customer_data.txt` | `Sriram_support` |
| 12:00 UTC / 17:30 IST | Triggered manual AWS Backup job: `aws backup start-backup-job --backup-vault-name flask-app-backup-vault --resource-arn arn:aws:ec2:us-east-1:<AWS_ACCOUNT_ID>:instance/i-03ea35ccf12929d50 --iam-role-arn <BACKUP_SERVICE_ROLE_ARN>` -> BackupJobId `1d9cb51d-740c-4b80-84ac-0d886ed09426` | `Sriram_support` |
| 12:09 UTC / 17:39 IST | Backup job completed successfully (`State: COMPLETED`, `PercentDone: 100.0`). Recovery point created as AMI: `arn:aws:ec2:us-east-1::image/ami-0462b005fd67d30cd` | AWS Backup |
| 12:10 UTC / 17:40 IST | Simulated data loss via SSM (`Sriram_support-ib2ryss6qohlxujx3xix4nj4ay`): `sudo rm /opt/flask-app/customer_data.txt` | `Sriram_support` |
| 12:15 UTC / 17:45 IST | Initiated restore job via AWS CLI (`support-analyst` profile). Encountered requirement for specific `--metadata` parameter | `Sriram_support` |
| 12:20 UTC / 17:50 IST | Queried recovery point restore metadata (`GetRecoveryPointRestoreMetadata`) to obtain correct EC2 restore parameter schema | `Sriram_support` |
| 12:25 UTC / 17:55 IST | Launched restore job `fc4418eb-b4c1-4a6b-9ffe-f8c343805153` with metadata JSON: `{"SubnetId":"subnet-0941950b9ebc5a474","SecurityGroupIds":"[\"sg-0a20a185f6897c2b0\"]","InstanceType":"t3.micro","IamInstanceProfileName":"flask-ec2-instance-profile"}` | `Sriram_support` |
| 12:26 UTC / 17:56 IST | Restore job completed (`Status: COMPLETED`). Provisioned new restored EC2 instance: `i-01c2e9d892ba80ea2` (`172.31.92.37`) | AWS Backup |
| 12:41 UTC / 18:11 IST | Connected to restored instance `i-01c2e9d892ba80ea2` via SSM (`Sriram_support-g6g6liqa5h49jfxvltatryer5a`). Inspected `/opt/flask-app/`: `app.py` present; `customer_data.txt` returned `FILE NOT FOUND` | `Sriram_support` |

---

## Technical Findings & Real-World Diagnostic Nuance

### Scoped IAM Permission Errors Handled
During execution under the scoped support analyst persona (`Sriram_support`), two specific IAM authorization errors occurred and were documented:
1. `backup:GetRecoveryPointRestoreMetadata` missing from policy when executing restore metadata lookup.
2. `iam:PassRole` required on `<BACKUP_SERVICE_ROLE_ARN>` when calling `start-restore-job`.

### AWS Backup Format Gotcha
Passing `--metadata` for EC2 restores requires `SecurityGroupIds` to be formatted as an escaped JSON array string (e.g. `'{"SecurityGroupIds":"[\"sg-0a20a185f6897c2b0\"]",...}'`). Unescaped or invalid string formatting caused initial restore job failure (`8e520334-00a4-499f-933b-eeea881048bb` with message `"Restore metadata is invalid."`).

### Point-in-Time Consistency Finding
While AWS Backup reported job completion (`COMPLETED`) and produced a healthy restored instance (`i-01c2e9d892ba80ea2`), the specific file `customer_data.txt` (written right before manual backup execution) was missing. This occurred because AMI creation captures block storage state at the exact moment of initial AMI registration.

**Key Technical Takeaway:** A `COMPLETED` backup job status validates mechanism execution, but does **not** guarantee application point-in-time data consistency for files created immediately prior to execution. Support analysts must always log in to the restored instance and verify data directly rather than assuming job completion equals full data recovery.

---

## Command Outputs & Empirical Evidence

### Manual Backup Creation Output
```json
{
    "BackupJobId": "1d9cb51d-740c-4b80-84ac-0d886ed09426",
    "CreationDate": "2026-07-26T17:30:45.790000+05:30",
    "IsParent": false
}
```

### Recovery Point Details
- **RecoveryPointArn**: `arn:aws:ec2:us-east-1::image/ami-0462b005fd67d30cd`
- **BackupSizeInBytes**: `8589934592` (8 GiB)
- **KMS Key**: `arn:aws:kms:us-east-1:<AWS_ACCOUNT_ID>:key/80572406-082c-414e-9095-c11a95d8aad9`

### Successful Restore Job Command
```bash
aws backup start-restore-job \
  --recovery-point-arn "arn:aws:ec2:us-east-1::image/ami-0462b005fd67d30cd" \
  --iam-role-arn <BACKUP_SERVICE_ROLE_ARN> \
  --resource-type EC2 \
  --metadata '{"SubnetId":"subnet-0941950b9ebc5a474","SecurityGroupIds":"[\"sg-0a20a185f6897c2b0\"]","InstanceType":"t3.micro","IamInstanceProfileName":"flask-ec2-instance-profile"}' \
  --profile support-analyst
```

**Output:**
```json
{
    "RestoreJobId": "fc4418eb-b4c1-4a6b-9ffe-f8c343805153"
}
```

### Successful Restore Status
```json
{
    "AccountId": "<AWS_ACCOUNT_ID>",
    "RestoreJobId": "fc4418eb-b4c1-4a6b-9ffe-f8c343805153",
    "RecoveryPointArn": "arn:aws:ec2:us-east-1::image/ami-0462b005fd67d30cd",
    "Status": "COMPLETED",
    "PercentDone": "100.00%",
    "CreatedResourceArn": "arn:aws:ec2:us-east-1:<AWS_ACCOUNT_ID>:instance/i-01c2e9d892ba80ea2"
}
```

### Restored Instance Direct Verification Output
SSM Session ID: `Sriram_support-g6g6liqa5h49jfxvltatryer5a`
```bash
sh-5.2$ ls /opt/flask-app/
app.py
sh-5.2$ cat /opt/flask-app/customer_data.txt 2>/dev/null || echo "FILE NOT FOUND"
FILE NOT FOUND
```
