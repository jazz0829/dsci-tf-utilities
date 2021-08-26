module "lambda_app_run_emr_job" {
  source                      = "git@github.com:exactsoftware/dsci-tf-modules.git//src/modules/lambda_localfile?ref=v0.0.19"
  app_name                    = "${local.cig_cig_sagemaker_run_emr_job_function_name}"
  description                 = "Lambda function to start an emr job"
  iam_policy_document         = "${data.aws_iam_policy_document.run_emr_job_lambda_iam_role.json}"
  assume_role_policy_document = "${data.aws_iam_policy_document.lambda_assume_role.json}"
  lambda_filename             = "${data.archive_file.run_emr_job_lambda_archive_file.0.output_path}"
  lambda_source_code_hash     = "${data.archive_file.run_emr_job_lambda_archive_file.0.output_base64sha256}"
  handler                     = "${var.handler}"
  runtime                     = "${var.runtime}"

  environment_variables = {
    FOO = "bar"
  }

  alarm_action_arn               = ""
  monitoring_enabled             = 0
  iteratorage_monitoring_enabled = false
  timeout                        = 10
  tags                           = "${var.default_tags}"
}

data "null_data_source" "run_emr_job_lambda_file" {
  inputs {
    filename = "${substr("${path.module}/functions/run-emr-job/handler.py", length(path.cwd) + 1, -1)}"
  }
}

data "null_data_source" "run_emr_job_lambda_archive" {
  inputs {
    filename = "${substr("${path.module}/functions/run-emr-job/cig-sagemaker-run-emr-job.zip", length(path.cwd) + 1, -1)}"
  }
}

data "archive_file" "run_emr_job_lambda_archive_file" {
  type        = "zip"
  source_file = "${data.null_data_source.run_emr_job_lambda_file.outputs.filename}"
  output_path = "${data.null_data_source.run_emr_job_lambda_archive.outputs.filename}"
}
