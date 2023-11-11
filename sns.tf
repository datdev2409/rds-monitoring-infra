resource "aws_sns_topic" "sns_topic" {
  name   = "event-monitoring-sns-topic"
  policy = templatefile("${path.module}/policies/sns_access_policy.json", {})
}

resource "aws_sns_topic_subscription" "sns_topic_subscription" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = "datdev2409+aws@gmail.com"
}
