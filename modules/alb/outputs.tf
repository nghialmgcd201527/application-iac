output "http_listener_arn" {
  value = aws_lb_listener.http_listener.arn
}


output "https_listener_arn" {
  value = aws_lb_listener.https_listener.arn
}


output "api_sns_alarm_arm" {
  value = aws_sns_topic.api_sns_alarm.arn
}
