data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_iam_role" {
  statement {
    effect = "Allow"

    actions = [
      "sns:Publish",
    ]

    resources = [
      "${data.aws_sns_topic.error_topic.arn}",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeTags",
      "ec2:StopInstances",
      "ec2:DescribeInstances",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

data "aws_sns_topic" "error_topic" {
  name = "${var.error_topic_name}"
}

data "aws_iam_policy_document" "glue_endpoints_remover_lambda_iam_role" {
  statement {
    effect = "Allow"

    actions = [
      "sns:Publish",
    ]

    resources = [
      "${data.aws_sns_topic.error_topic.arn}",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "glue:DeleteDevEndpoint",
      "glue:GetDevEndpoints",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

data "aws_iam_policy_document" "security_group_autocorrect_lambda_iam_role" {
  statement {
    effect = "Allow"

    actions = [
      "sns:Publish",
    ]

    resources = [
      "${data.aws_sns_topic.error_topic.arn}",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:RevokeSecurityGroupIngress",
      "ec2:DescribeSecurityGroups",
      "ec2:AuthorizeSecurityGroupIngress",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

data "aws_sns_topic" "info_topic" {
  name = "${var.info_topic_name}"
}

data "aws_iam_policy_document" "batch_transform_status_lambda_iam_role" {
  statement {
    effect = "Allow"

    actions = [
      "sagemaker:DescribeTransformJob",
      "iam:PassRole",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

data "aws_iam_policy_document" "create_batch_transform_job_lambda_iam_role" {
  statement {
    effect = "Allow"

    actions = [
      "sagemaker:ListModels",
      "sagemaker:DescribeModel",
      "sagemaker:CreateTransformJob",
      "iam:PassRole",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

data "aws_iam_policy_document" "query_athena_lambda_iam_role" {
  statement {
    effect = "Allow"

    actions = [
      "athena:StartQueryExecution",
      "athena:GetQueryExecution",
      "iam:PassRole",
      "glue:GetTable",
      "s3:ListBucket",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::aws-athena-query-results-${var.accountid}-eu-west-1/*",
      "arn:aws:s3:::aws-athena-query-results-${var.accountid}-eu-west-1",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::cig-${var.environment}-domain-bucket/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

data "aws_iam_policy_document" "glue_job_status_lambda_iam_role" {
  statement {
    effect = "Allow"

    actions = [
      "glue:GetJobRun",
      "iam:PassRole",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

data "aws_iam_policy_document" "run_glue_job_lambda_iam_role" {
  statement {
    effect = "Allow"

    actions = [
      "glue:StartJobRun",
      "iam:PassRole",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

data "aws_iam_policy_document" "slack_lambda_iam_role" {
  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

data "aws_iam_policy_document" "get_emr_cluster_status_lambda_iam_role" {
  statement {
    effect = "Allow"

    actions = [
      "elasticmapreduce:DescribeCluster",
      "iam:PassRole",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

data "aws_iam_policy_document" "run_emr_job_lambda_iam_role" {
  statement {
    effect = "Allow"

    actions = [
      "elasticmapreduce:RunJobFlow",
      "iam:PassRole",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${var.artifact_store_bucket}",
      "arn:aws:s3:::${var.artifact_store_bucket}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

data "aws_iam_policy_document" "create_model_lambda_iam_role" {
  statement {
    effect = "Allow"

    actions = [
      "sagemaker:CreateModel",
      "iam:PassRole",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

data "aws_iam_policy_document" "training_job_status_lambda_iam_role" {
  statement {
    effect = "Allow"

    actions = [
      "sagemaker:DescribeTrainingJob",
      "iam:PassRole",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

data "aws_iam_policy_document" "s3_openaccess_responder_lambda_iam_role" {
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [
      "${data.aws_sns_topic.error_topic.arn}",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl",
      "s3:GetBucketPolicy"
    ]
    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutBucketAcl",
      "s3:DeleteBucketPolicy"
    ]
    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}
