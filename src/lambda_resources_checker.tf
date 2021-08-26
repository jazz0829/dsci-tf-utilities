module "lambda_app" {
  source                      = "git@github.com:exactsoftware/dsci-tf-modules.git//src/modules/lambda_localfile?ref=v0.0.19"
  app_name                    = "${local.cig_resource_checker_function_name}"
  description                 = "AWS Lambda to stop all EC2 instances that are currently running without pre-configured tags"
  iam_policy_document         = "${data.aws_iam_policy_document.lambda_iam_role.json}"
  assume_role_policy_document = "${data.aws_iam_policy_document.lambda_assume_role.json}"
  lambda_filename             = "${data.archive_file.cig_resource_checker.0.output_path}"
  lambda_source_code_hash     = "${data.archive_file.cig_resource_checker.0.output_base64sha256}"
  handler                     = "${var.handler}"
  runtime                     = "${var.runtime}"

  environment_variables = {
    TOPIC_ARN = "${data.aws_sns_topic.error_topic.arn}"
  }

  alarm_action_arn               = "${data.aws_sns_topic.error_topic.arn}"
  monitoring_enabled             = 0
  iteratorage_monitoring_enabled = false
  timeout                        = 10
  tags                           = "${var.default_tags}"
}

data "null_data_source" "lambda_file" {
  inputs {
    filename = "${substr("${path.module}/functions/resource-checker/handler.py", length(path.cwd) + 1, -1)}"
  }
}

data "null_data_source" "lambda_archive" {
  inputs {
    filename = "${substr("${path.module}/functions/resource-checker/cig_resource_checker.zip", length(path.cwd) + 1, -1)}"
  }
}

data "archive_file" "cig_resource_checker" {
  type        = "zip"
  source_file = "${data.null_data_source.lambda_file.outputs.filename}"
  output_path = "${data.null_data_source.lambda_archive.outputs.filename}"
}
