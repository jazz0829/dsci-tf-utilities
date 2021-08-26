module "lambda_app_slack" {
  source                      = "git@github.com:exactsoftware/dsci-tf-modules.git//src/modules/lambda_localfile?ref=v0.0.19"
  app_name                    = "${local.cig_sagemaker_slack_function_name}"
  description                 = "Lambda function to post messages to slack"
  iam_policy_document         = "${data.aws_iam_policy_document.slack_lambda_iam_role.json}"
  assume_role_policy_document = "${data.aws_iam_policy_document.lambda_assume_role.json}"
  lambda_filename             = "${data.archive_file.sagemaker_slack_lambda_archive_file.0.output_path}"
  lambda_source_code_hash     = "${data.archive_file.sagemaker_slack_lambda_archive_file.0.output_base64sha256}"
  handler                     = "${var.handler}"
  runtime                     = "${var.nodejs10_runtime}"

  environment_variables = {
    FOO = "bar"
  }

  alarm_action_arn               = ""
  monitoring_enabled             = 0
  iteratorage_monitoring_enabled = false
  timeout                        = 10
  tags                           = "${var.default_tags}"
}

data "null_data_source" "sagemaker_slack_lambda_file" {
  inputs {
    filename = "${substr("${path.module}/functions/slack/handler.js", length(path.cwd) + 1, -1)}"
  }
}

data "null_data_source" "sagemaker_slack_lambda_archive" {
  inputs {
    filename = "${substr("${path.module}/functions/slack/cig-sagemaker-slack.zip", length(path.cwd) + 1, -1)}"
  }
}

data "archive_file" "sagemaker_slack_lambda_archive_file" {
  type        = "zip"
  source_file = "${data.null_data_source.sagemaker_slack_lambda_file.outputs.filename}"
  output_path = "${data.null_data_source.sagemaker_slack_lambda_archive.outputs.filename}"
}
