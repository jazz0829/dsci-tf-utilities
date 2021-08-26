module "lambda_s3_openaccess_responder" {
  source                      = "git@github.com:exactsoftware/dsci-tf-modules.git//src/modules/lambda_localfile?ref=v0.0.19"
  app_name                    = "${local.cig_s3_openaccess_responder_function_name}"
  description                 = "lambda to dynamically secure buckets opened to public by mistake"
  iam_policy_document         = "${data.aws_iam_policy_document.s3_openaccess_responder_lambda_iam_role.json}"
  assume_role_policy_document = "${data.aws_iam_policy_document.lambda_assume_role.json}"
  lambda_filename             = "${data.archive_file.s3_openaccess_responder_archive_file.0.output_path}"
  lambda_source_code_hash     = "${data.archive_file.s3_openaccess_responder_archive_file.0.output_base64sha256}"
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

data "null_data_source" "lambda_s3_openaccess_responder_file" {
  inputs {
    filename = "${substr("${path.module}/functions/s3-openaccess-responder/handler.py", length(path.cwd) + 1, -1)}"
  }
}

data "null_data_source" "lambda_s3_openaccess_responder_archive" {
  inputs {
    filename = "${substr("${path.module}/functions/s3-openaccess-responder/cig-s3-openaccess-responder.zip", length(path.cwd) + 1, -1)}"
  }
}

data "archive_file" "s3_openaccess_responder_archive_file" {

  type        = "zip"
  source_file = "${data.null_data_source.lambda_s3_openaccess_responder_file.outputs.filename}"
  output_path = "${data.null_data_source.lambda_s3_openaccess_responder_archive.outputs.filename}"
}

