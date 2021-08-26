module "lambda_glue_endpoints_remover_app" {
  source                      = "git@github.com:exactsoftware/dsci-tf-modules.git//src/modules/lambda_localfile?ref=v0.0.19"
  app_name                    = "${local.cig_glue_endpoints_remover_function_name}"
  description                 = "AWS Lambda to delete all glue development endpoints at 7 PM utc everyday"
  iam_policy_document         = "${data.aws_iam_policy_document.glue_endpoints_remover_lambda_iam_role.json}"
  assume_role_policy_document = "${data.aws_iam_policy_document.lambda_assume_role.json}"
  lambda_filename             = "${data.archive_file.glue_endpoints_remover.0.output_path}"
  lambda_source_code_hash     = "${data.archive_file.glue_endpoints_remover.0.output_base64sha256}"
  handler                     = "${var.handler}"

  environment_variables = {
    TOPIC_ARN = "${data.aws_sns_topic.error_topic.arn}"
  }

  alarm_action_arn               = "${data.aws_sns_topic.error_topic.arn}"
  monitoring_enabled             = 0
  iteratorage_monitoring_enabled = false
  timeout                        = 10
  tags                           = "${var.default_tags}"
}

data "null_data_source" "lambda_glue_endpoints_remover_file" {
  inputs {
    filename = "${substr("${path.module}/functions/remove-glue-endpoints/handler.py", length(path.cwd) + 1, -1)}"
  }
}

data "null_data_source" "lambda_glue_endpoints_remover_archive" {
  inputs {
    filename = "${substr("${path.module}/functions/remove-glue-endpoints/glue_endpoints_remover.zip", length(path.cwd) + 1, -1)}"
  }
}

data "archive_file" "glue_endpoints_remover" {
  type        = "zip"
  source_file = "${data.null_data_source.lambda_glue_endpoints_remover_file.outputs.filename}"
  output_path = "${data.null_data_source.lambda_glue_endpoints_remover_archive.outputs.filename}"
}
