terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"   # Or a version known to support role_arn for Firehose
    }
  }
}


#######
# 1. Logging Configuration  #
#############################

# Create a CloudWatch Log Group for application logs
resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "/aws/application/logs"
  retention_in_days = var.log_retention_days
}

# Create a CloudWatch Log Stream
resource "aws_cloudwatch_log_stream" "app_log_stream" {
  name           = "app-stream"
  log_group_name = aws_cloudwatch_log_group.application_logs.name
}

# IAM Role for Kinesis Firehose
# IAM Role for Kinesis Firehose
resource "aws_iam_role" "firehose_role" {
  name        = "firehose-splunk-role"
  description = "IAM Role that allows Kinesis Firehose to send logs to Splunk."

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = "sts:AssumeRole",
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })
}


# Attach required policy to the Firehose Role
resource "aws_iam_policy_attachment" "firehose_logs" {
  name       = "firehose-logs-attachment"
  roles      = [aws_iam_role.firehose_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFirehoseFullAccess"
}

# Create a Kinesis Firehose Delivery Stream to send logs to Splunk
resource "aws_kinesis_firehose_delivery_stream" "splunk_stream" {
  name        = "splunk-logs-stream"
  destination = "splunk"
   #role_arn       = aws_iam_role.firehose_role.arn 

  splunk_configuration {
    hec_endpoint       = var.splunk_hec_endpoint
    hec_token          = var.splunk_hec_token
    #hec_acknowledgment = true
    

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.application_logs.name
      log_stream_name = aws_cloudwatch_log_stream.app_log_stream.name
    }
  

  s3_configuration {
    bucket_arn         = var.firehose_backup_bucket_arn
    role_arn           = var.firehose_backup_role_arn
    buffering_interval = 300
    buffering_size     = 5
    compression_format = "UNCOMPRESSED"
  }

  }
  depends_on = [aws_iam_policy_attachment.firehose_logs]
}



###################################
# 2. Cloud Asset Tagging Example  #
###################################

# Example EC2 Instance with resource tagging
resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = var.tags
}

#####################################
# 3. Health Checks & Alerts Setup   #
#####################################

# Create a CloudWatch Alarm for High CPU Utilization
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "HighCPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "Triggers when CPU utilization exceeds ${var.cpu_threshold}% for 2 consecutive minutes"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = aws_instance.example.id
  }
}

# Create an SNS Topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "aws-monitoring-alerts"
}

# Subscribe an email address to the SNS Topic
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

####################################
# 4. CloudWatch Dashboard Creation #
####################################

resource "aws_cloudwatch_dashboard" "monitoring_dashboard" {
  dashboard_name = "System-Monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric",
        x      = 0,
        y      = 0,
        width  = 6,
        height = 6,
        properties = {
          metrics     = [
            [ "AWS/EC2", "CPUUtilization", "InstanceId", aws_instance.example.id ]
          ],
          period      = 60,
          stat        = "Average",
          title       = "CPU Utilization",
          region      = var.aws_region,    # Add the region property
          annotations = {}                 # Add an empty annotations object
        }
      },
      {
        type   = "metric",
        x      = 6,
        y      = 0,
        width  = 6,
        height = 6,
        properties = {
          metrics     = [
            [ "AWS/EC2", "NetworkIn", "InstanceId", aws_instance.example.id ]
          ],
          period      = 60,
          stat        = "Sum",
          title       = "Network In",
          region      = var.aws_region,    # Add the region property
          annotations = {}                 # Add an empty annotations object
        }
      }
    ]
  })
}

