resource "aws_cloudwatch_event_rule" "cig_sec_group_changed_rule" {
  name        = "${local.cig_security_group_ingress_authorized_rule_name}"
  description = "Trigger an AWS Lambda whenever an EC2 security group ingress is changed"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.ec2"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "ec2.amazonaws.com"
    ],
    "eventName": [
      "AuthorizeSecurityGroupIngress"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "target_lambda_sec_group_autocorrect" {
  target_id = "cig-sec-group-checker"
  arn       = "${module.lambda_security_group_autocorrect_app.lambda_arn}"
  rule      = "${aws_cloudwatch_event_rule.cig_sec_group_changed_rule.name}"
}

resource "aws_lambda_permission" "allow_cloudwatch_sec_group_autocorrect" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${module.lambda_security_group_autocorrect_app.lambda_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.cig_sec_group_changed_rule.arn}"
}
