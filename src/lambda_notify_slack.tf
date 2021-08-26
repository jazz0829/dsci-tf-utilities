resource "aws_lambda_permission" "sns_notify_slack_info" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.notify_info_slack.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${data.aws_sns_topic.info_topic.arn}"
}

resource "aws_lambda_permission" "sns_notify_slack_error" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.notify_error_slack.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${data.aws_sns_topic.error_topic.arn}"
}

data "null_data_source" "slack_lambda_file" {
  inputs {
    filename = "${substr("${path.module}/functions/notify-slack/handler.py", length(path.cwd) + 1, -1)}"
  }
}

data "null_data_source" "slack_lambda_archive" {
  inputs {
    filename = "${substr("${path.module}/functions/notify-slack/notify_slack.zip", length(path.cwd) + 1, -1)}"
  }
}

data "archive_file" "notify_slack" {
  type        = "zip"
  source_file = "${data.null_data_source.slack_lambda_file.outputs.filename}"
  output_path = "${data.null_data_source.slack_lambda_archive.outputs.filename}"
}

resource "aws_lambda_function" "notify_info_slack" {
  filename      = "${data.archive_file.notify_slack.0.output_path}"
  function_name = "InfoSNSSlack"

  role             = "${aws_iam_role.lambda_role.arn}"
  handler          = "handler.lambda_handler"
  source_code_hash = "${data.archive_file.notify_slack.0.output_base64sha256}"
  runtime          = "python3.6"
  timeout          = 30

  environment {
    variables = {
      SLACK_WEBHOOK_URL = "${var.slack_info_webhook_url}"
      SLACK_CHANNEL     = "${var.slack_info_channel}"
      SLACK_USERNAME    = "${var.slack_username}"
      SLACK_EMOJI       = "${var.slack_emoji}"
    }
  }

  lifecycle {
    ignore_changes = [
      "filename",
      "last_modified",
    ]
  }
}

resource "aws_lambda_function" "notify_error_slack" {
  filename      = "${data.archive_file.notify_slack.0.output_path}"
  function_name = "ErrorSNSSlack"

  role             = "${aws_iam_role.lambda_role.arn}"
  handler          = "notify_slack.lambda_handler"
  source_code_hash = "${data.archive_file.notify_slack.0.output_base64sha256}"
  runtime          = "python3.6"
  timeout          = 30

  environment {
    variables = {
      SLACK_WEBHOOK_URL = "${var.slack_error_webhook_url}"
      SLACK_CHANNEL     = "${var.slack_error_channel}"
      SLACK_USERNAME    = "${var.slack_username}"
      SLACK_EMOJI       = "${var.slack_emoji}"
    }
  }

  lifecycle {
    ignore_changes = [
      "filename",
      "last_modified",
    ]
  }
}

resource "aws_sns_topic_subscription" "sns_info_slack" {
  topic_arn = "${data.aws_sns_topic.info_topic.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.notify_info_slack.0.arn}"
}

resource "aws_sns_topic_subscription" "sns_error_slack" {
  topic_arn = "${data.aws_sns_topic.error_topic.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.notify_error_slack.0.arn}"
}

resource "aws_cloudwatch_log_group" "lambda_log_group_info" {
  name              = "/aws/lambda/${aws_lambda_function.notify_info_slack.function_name}"
  retention_in_days = "${var.codebuild_loggroup_retention_days}"
}

resource "aws_cloudwatch_log_group" "lambda_log_group_info_error" {
  name              = "/aws/lambda/${aws_lambda_function.notify_error_slack.function_name}"
  retention_in_days = "${var.codebuild_loggroup_retention_days}"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-notify-slack"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "rolepolicy" {
  name = "lambda-notify-slack-role-policy"
  role = "${aws_iam_role.lambda_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}
