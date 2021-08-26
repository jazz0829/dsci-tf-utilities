module "sns_s3_public_readwrite_notifications" {
  source     = "git@github.com:exactsoftware/dsci-tf-modules.git//src/modules/sns_topic?ref=v0.0.9"
  region     = "${var.region}"
  topic_name = "${var.sns_topic}"
}
