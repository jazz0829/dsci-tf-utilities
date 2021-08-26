resource "aws_cloudwatch_event_rule" "notifications_awsconfig_s3_public_readwrite" {
  name        = "notifications-awsconfig-s3-public-readwrite"
  description = "Trigger the info notifications when s3 object changed to public access"

  event_pattern = <<PATTERN
  {
      "source": [
          "aws.config"
          ],
      "detail": {
          "requestParameters": {
              "evaluations": {
                  "complianceType": [
                      "NON_COMPLIANT"
                      ]
              }
          },
          "additionalEventData": {
              "managedRuleIdentifier": [
                  "S3_BUCKET_PUBLIC_READ_PROHIBITED",
                  "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
              ]
          }
      }
  }
PATTERN
}

resource "aws_lambda_permission" "allow_cloudwatch_s3_openaccess_responder" {
  statement_id   = "AllowExecutionFromCloudWatch"
  action         = "lambda:InvokeFunction"
  function_name  = "${module.lambda_s3_openaccess_responder.lambda_name}"
  principal      = "events.amazonaws.com"
  source_arn     = "${aws_cloudwatch_event_rule.notifications_awsconfig_s3_public_readwrite.arn}"
}

resource "aws_cloudwatch_event_target" "target_error_sns" {
  target_id = "lambda-open-access-responder"
  arn       = "${module.lambda_s3_openaccess_responder.lambda_arn}"
  rule      = "${aws_cloudwatch_event_rule.notifications_awsconfig_s3_public_readwrite.name}"
}

resource "aws_config_config_rule" "s3_bucket_publicread_prohibhited" {
  name = "s3-bucket-public-read-prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
}

resource "aws_config_config_rule" "s3_bucket_publicwrite_prohibhited" {
  name = "s3-bucket-public-write-prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
  }
}