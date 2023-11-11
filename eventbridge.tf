resource "aws_cloudwatch_event_rule" "event_rule" {
  name        = "event-monitoring-event-rule"
  description = "Event rule for monitoring events"
  event_pattern = jsonencode(
    {
      "source" : ["aws.rds"],
      "detail-type" : ["RDS DB Instance Event"]
      # "detail" : {
      #   "EventID" : ["RDS-EVENT-0049", "RDS-EVENT-0004"]
      # }
  })
}

resource "aws_cloudwatch_event_target" "lambda_event_target" {
  rule      = aws_cloudwatch_event_rule.event_rule.name
  target_id = "event-monitoring-lambda-event-target"
  arn       = aws_lambda_function.noti_forwarder.arn
}
