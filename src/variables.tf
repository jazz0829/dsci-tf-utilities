variable "region" {
  default = "eu-west-1"
}

variable "default_tags" {
  description = "Map of tags to add to all resources"
  type        = "map"

  default = {
    Terraform   = "true"
    GitHub-Repo = "exactsoftware/dsci-tf-utilities"
  }
}

variable "error_topic_name" {
  default = "cig-notifications-error"
}

variable "info_topic_name" {
  default = "cig-notifications-info"
}

variable "slack_info_webhook_url" {
  description = "The URL of Slack webhook"
  default     = "https://hooks.slack.com/services/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"
}

variable "slack_info_channel" {
  description = "The name of the channel in Slack for info notifications"
  default     = "cig-info-monitor"
}

variable "slack_error_channel" {
  description = "The name of the channel in Slack for error notifications"
  default     = "cig-error-monitor"
}

variable "slack_emoji" {
  description = "A custom emoji that will appear on Slack messages"
  default     = ":aws:"
}

variable "slack_username" {
  description = "The username that will appear on Slack messages"
}

variable "slack_error_webhook_url" {
  description = "The URL of Slack webhook"
  default     = "https://hooks.slack.com/services/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"
}

variable "codebuild_loggroup_retention_days" {
  default = 30
}

variable "environment" {}

variable "handler" {
  default = "handler.lambda_handler"
}

variable "runtime" {
  default = "python3.7"
}

variable "nodejs10_runtime" {
  default = "nodejs10.x"
}

variable "artifact_store_bucket" {
  default = "cig-build-artifact-store"
}

variable "sns_topic" {
  default = "s3_public_readwrite_alert"
}

variable "accountid" {}
