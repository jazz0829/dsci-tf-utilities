module "lambda_security_group_autocorrect_app" {
  source                      = "git@github.com:exactsoftware/dsci-tf-modules.git//src/modules/lambda_localfile?ref=v0.0.19"
  app_name                    = "${local.cig_security_group_autocorrect_function_name}"
  description                 = "AWS Lambda to autocorrect vulnerable security groups"
  iam_policy_document         = "${data.aws_iam_policy_document.security_group_autocorrect_lambda_iam_role.json}"
  assume_role_policy_document = "${data.aws_iam_policy_document.lambda_assume_role.json}"
  lambda_filename             = "${data.archive_file.security_group_autocorrect_archive.0.output_path}"
  lambda_source_code_hash     = "${data.archive_file.security_group_autocorrect_archive.0.output_base64sha256}"
  handler                     = "${var.handler}"

  environment_variables = {
    TOPIC_ARN = "${data.aws_sns_topic.error_topic.arn}"
  }

  alarm_action_arn               = "${data.aws_sns_topic.error_topic.arn}"
  monitoring_enabled             = 0
  iteratorage_monitoring_enabled = false
  timeout                        = 20
  tags                           = "${var.default_tags}"
}

data "null_data_source" "lambda_security_group_autocorrect_file" {
  inputs {
    filename = "${substr("${path.module}/functions/security-group-autocorrect/handler.py", length(path.cwd) + 1, -1)}"
  }
}

data "null_data_source" "lambda_security_group_autocorrect_archive" {
  inputs {
    filename = "${substr("${path.module}/functions/security-group-autocorrect/security-group-autocorrect.zip", length(path.cwd) + 1, -1)}"
  }
}

data "archive_file" "security_group_autocorrect_archive" {
  type        = "zip"
  source_file = "${data.null_data_source.lambda_security_group_autocorrect_file.outputs.filename}"
  output_path = "${data.null_data_source.lambda_security_group_autocorrect_archive.outputs.filename}"
}
