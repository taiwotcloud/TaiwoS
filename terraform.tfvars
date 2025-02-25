aws_region          = "us-east-1"
log_retention_days  = 30

# Splunk configuration
splunk_hec_endpoint = "https://splunk.example.com:8088"
splunk_hec_token    = "your-splunk-hec-token-here"

# EC2 instance configuration
ami_id              = "ami-04b4f1a9cf54c11d0"
instance_type       = "t3.micro"

# Common resource tags
tags = {
  Environment = "Production"
  Owner       = "DevOps Team"
  CostCenter  = "FPAC"
  Compliance  = "Yes"
}

# Alarm and notification settings
cpu_threshold = 75
alert_email   = "your-email@example.com"

firehose_backup_bucket_arn = "arn:aws:s3:::your-backup-bucket-name"

firehose_backup_role_arn = "arn:aws:iam::340752812984:role/my-firehose-backup-role"


