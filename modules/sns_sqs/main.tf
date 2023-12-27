resource "aws_sns_topic" "main" {
  count = var.is_sns_enabled ? 1 : 0

  name            = "${var.project_name}-${var.service_name}-event"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false
  }
}
EOF
}

resource "aws_ssm_parameter" "sns" {
  count = var.is_sns_enabled ? 1 : 0
  name  = "/${var.service_name}/${var.stage}/AWS_SNS_EVENT_TOPIC_ARN"
  type  = "String"
  value = aws_sns_topic.main[0].arn
}

resource "aws_sqs_queue" "main_dlq" {
  name                       = "${var.project_name}-${var.service_name}-event-dlq"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 345600
  receive_wait_time_seconds  = 10
  visibility_timeout_seconds = 300
  sqs_managed_sse_enabled    = var.is_encrypted
  tags = {
    Environment = "${var.stage}"
  }
}

resource "aws_ssm_parameter" "dlq" {
  name  = "/${var.service_name}/${var.stage}/AWS_SQS_DLQ_URL"
  type  = "String"
  value = aws_sqs_queue.main_dlq.id
}

resource "aws_sqs_queue" "event_queue" {
  name                       = "${var.project_name}-${var.service_name}-event-queue"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 3600
  receive_wait_time_seconds  = 0
  visibility_timeout_seconds = 300
  sqs_managed_sse_enabled    = var.is_encrypted
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.main_dlq.arn
    maxReceiveCount     = 10
  })
  tags = {
    Environment = "${var.stage}"
  }
}
resource "aws_ssm_parameter" "event_queue" {
  name  = "/${var.service_name}/${var.stage}/AWS_SQS_QUEUE_URL"
  type  = "String"
  value = aws_sqs_queue.event_queue.id
}
