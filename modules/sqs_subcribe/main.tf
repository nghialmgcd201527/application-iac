data "template_file" "sqspolicy" {
  template = file("${path.module}/policy.json")

  vars = {
    sns_topic_arn = var.sns_arn
    sqs_queue_arn = var.sqs_arn
    account_id    = var.account_id
  }
}
resource "aws_sns_topic_subscription" "main" {
  topic_arn            = var.sns_arn
  protocol             = "sqs"
  endpoint             = var.sqs_arn
  raw_message_delivery = true
}

resource "aws_sqs_queue_policy" "main" {
  queue_url = var.sqs_url
  policy    = data.template_file.sqspolicy.rendered
}
