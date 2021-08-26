module "lambda_app_query_athena" {
  source                      = "git@github.com:exactsoftware/dsci-tf-modules.git//src/modules/lambda_localfile?ref=v0.0.19"
  app_name                    = "${local.cig_sagemaker_query_athena_function_name}"
  description                 = "Lambda function to query athena"
  iam_policy_document         = "${data.aws_iam_policy_document.query_athena_lambda_iam_role.json}"
  assume_role_policy_document = "${data.aws_iam_policy_document.lambda_assume_role.json}"
  lambda_filename             = "${data.archive_file.query_athena_lambda_archive_file.0.output_path}"
  lambda_source_code_hash     = "${data.archive_file.query_athena_lambda_archive_file.0.output_base64sha256}"
  handler                     = "${var.handler}"
  runtime                     = "${var.runtime}"

  environment_variables = {
    FOO = "bar"
  }

  alarm_action_arn               = ""
  monitoring_enabled             = 0
  iteratorage_monitoring_enabled = false
  timeout                        = 120
  tags                           = "${var.default_tags}"
}

data "null_data_source" "query_athena_lambda_file" {
  inputs {
    filename = "${substr("${path.module}/functions/query-athena/handler.py", length(path.cwd) + 1, -1)}"
  }
}

data "null_data_source" "query_athena_lambda_archive" {
  inputs {
    filename = "${substr("${path.module}/functions/query-athena/cig-sagemaker-query-athena.zip", length(path.cwd) + 1, -1)}"
  }
}

data "archive_file" "query_athena_lambda_archive_file" {
  type        = "zip"
  source_file = "${data.null_data_source.query_athena_lambda_file.outputs.filename}"
  output_path = "${data.null_data_source.query_athena_lambda_archive.outputs.filename}"
}
