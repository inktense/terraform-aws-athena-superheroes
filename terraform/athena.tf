resource "aws_athena_workgroup" "athena_workgroup" {
  name          = "${var.project_prefix}-query-workgroup"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${module.s3_athena_bucket.s3_bucket_id}/query-results/"
    }
  }
}
