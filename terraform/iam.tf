resource "aws_iam_role" "s3_glue_role" {
  name               = "${var.project_prefix}-s3-glue-role"
  assume_role_policy = data.aws_iam_policy_document.glue_role_trust.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "s3_glue_role_attachment" {
  role       = aws_iam_role.s3_glue_role.name
  policy_arn = aws_iam_policy.s3_glue_policy.arn
}

resource "aws_iam_role_policy_attachment" "s3_glue_aws_role_attachment" {
  role       = aws_iam_role.s3_glue_role.name
  policy_arn = data.aws_iam_policy.aws_glue_service_role.arn
}

resource "aws_iam_policy" "s3_glue_policy" {
  name = "${var.project_prefix}-GlueS3Policy"

  policy = data.aws_iam_policy_document.s3_glue_policy.json
}

data "aws_iam_policy_document" "s3_glue_policy" {
  policy_id = "${var.project_prefix}-s3-glue-policy"
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListAllMyBuckets",
      "s3:GetBucketAcl",
      "s3:GetObject",
    ]

    resources = [
      "${module.s3_athena_bucket.s3_bucket_arn}/",
      "${module.s3_athena_bucket.s3_bucket_arn}/*",
      "${module.s3_python_scripts_bucket.s3_bucket_arn}/",
      "${module.s3_python_scripts_bucket.s3_bucket_arn}/*",
    ]
  }
}
