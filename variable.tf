variable "aws_region" {
  description = "AWS region to deploy resources."
  type        = string
  default     = "us-east-1"
}

variable "log_retention_days" {
  description = "Retention period for CloudWatch logs (in days)."
  type        = number
  default     = 30
}

variable "splunk_hec_endpoint" {
  description = "Splunk HTTP Event Collector (HEC) endpoint URL."
  type        = string
}

variable "splunk_hec_token" {
  description = "Splunk HEC authentication token."
  type        = string
  sensitive   = true
}

variable "firehose_backup_bucket_arn" {
  description = "ARN of the S3 bucket for Firehose backup."
  type        = string
}

variable "firehose_backup_role_arn" {
  description = "ARN of the IAM role for Firehose backup S3 bucket."
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for the EC2 instance."
  type        = string
  default     = "ami-04b4f1a9cf54c11d0"  # Replace with the actual AMI ID
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "tags" {
  description = "Common tags for AWS resources."
  type        = map(string)
  default = {
    Environment = "Production"
    Owner       = "DevOps Team"
    CostCenter  = "FPAC"
    Compliance  = "Yes"
  }
}

variable "cpu_threshold" {
  description = "CPU utilization threshold percentage for triggering the alarm."
  type        = number
  default     = 75
}

variable "alert_email" {
  description = "Email address to receive SNS alerts."
  type        = string
  default     = "your-email@example.com"  # Replace with your actual email
}

