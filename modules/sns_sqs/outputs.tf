output "sns_id" {

  value = try(aws_sns_topic.main[0].id, null)
}

output "sqs_id" {
  value = aws_sqs_queue.event_queue.id
}

output "sqs_arn" {
  value = aws_sqs_queue.event_queue.arn
}


output "sqs_dlq_id" {
  value = aws_sqs_queue.main_dlq.id
}

output "sqs_dlq_arn" {
  value = aws_sqs_queue.main_dlq.arn
}
