resource "aws_cloudwatch_event_rule" "cig_ec2_state_running_rule" {
  name        = "cig-ec2-state-running-rule"
  description = "Trigger an AWS Lambda whenever an EC2 state changed to running"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.ec2"
  ],
  "detail-type": [
    "EC2 Instance State-change Notification"
  ],
  "detail": {
    "state": ["running"]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "target_lambda_endpoints_remover" {
  target_id = "cig-resource-checker"
  arn       = "${module.lambda_app.lambda_arn}"
  rule      = "${aws_cloudwatch_event_rule.cig_ec2_state_running_rule.name}"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${module.lambda_app.lambda_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.cig_ec2_state_running_rule.arn}"
}

resource "aws_cloudwatch_event_rule" "cig_glue_dev_endpoints_rule" {
  name        = "cig-glue-dev-endpoints-rule"
  description = "Trigger AWS Lambda to delete all glue development enpoints at the end of the day (7 PM utc)"

  schedule_expression = "cron(30 17 * * ? *)"
}

resource "aws_cloudwatch_event_target" "target_lambda_glue_endpoints_remover" {
  target_id = "glue-endpoints-remover"
  arn       = "${module.lambda_glue_endpoints_remover_app.lambda_arn}"
  rule      = "${aws_cloudwatch_event_rule.cig_glue_dev_endpoints_rule.name}"
}

resource "aws_lambda_permission" "allow_cloudwatch_glue_endpoints_remover" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${module.lambda_glue_endpoints_remover_app.lambda_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.cig_glue_dev_endpoints_rule.arn}"
}
