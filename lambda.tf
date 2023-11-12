module "lambda" {
  source        = "git@github.com:datdev2409/terraform-lambda-module.git?ref=master"
  source_file   = "${path.module}/lambdas/noti_forwarder.py"
  output_path   = "${path.module}/lambdas/noti_forwarder.zip"
  function_name = "noti_forwarder"
  resource_based_policies = [
    {
      statement_id = "AllowExecutionFromEventbridge"
      principal    = "events.amazonaws.com"
      source_arn   = aws_cloudwatch_event_rule.event_rule.arn
    }
  ]
  exec_inline_policy = templatefile("${path.module}/policies/lambda_publish_sns_policy.json", {
    aws_region     = "ap-southeast-1"
    account_id     = data.aws_caller_identity.current.account_id
    sns_topic_name = "event-monitoring-sns-topic"
  })
  exec_managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
  environment_variables = {
    SNS_TOPIC_ARN       = aws_sns_topic.sns_topic.arn
    DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1171680062924406834/sMTJq9rr7d29ViOiRrco2M-L-0LgKp2thOi7EYHMo1v7amOHAy_OezYY9RdsTCH57JKn"
  }
}
