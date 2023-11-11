data "archive_file" "lambda_code" {
  type        = "zip"
  source_file = "${path.module}/lambdas/noti_forwarder.py"
  output_path = "${path.module}/lambdas/noti_forwarder.zip"
}

resource "aws_lambda_permission" "eventbridge_permission" {
  statement_id  = "AllowExecutionFromEventbridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.noti_forwarder.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event_rule.arn
}

resource "aws_iam_role" "lambda_exec_role" {
  name               = "noti_forwarder_lambda_exec_role"
  assume_role_policy = templatefile("${path.module}/policies/lambda_assume_role_policy.json", {})

  inline_policy {
    name = "lambda_publish_sns_policy"
    policy = templatefile("${path.module}/policies/lambda_publish_sns_policy.json", {
      aws_region     = "ap-southeast-2"
      account_id     = data.aws_caller_identity.current.account_id
      sns_topic_name = "event-monitoring-sns-topic"
    })
  }

  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}

resource "aws_lambda_function" "noti_forwarder" {
  filename         = "${path.module}/lambdas/noti_forwarder.zip"
  function_name    = "noti_forwarder"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "noti_forwarder.lambda_handler"
  source_code_hash = data.archive_file.lambda_code.output_base64sha256
  runtime          = "python3.11"
  timeout          = 60
  memory_size      = 128

  environment {
    variables = {
      SNS_TOPIC_ARN       = aws_sns_topic.sns_topic.arn
      DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1171680062924406834/sMTJq9rr7d29ViOiRrco2M-L-0LgKp2thOi7EYHMo1v7amOHAy_OezYY9RdsTCH57JKn"
    }
  }
}
