resource "aws_glue_catalog_database" "glue_catalog_database" {
  name        = "${var.project_prefix}-glue-catalog"
  description = "Glue catalog database responsible for storing superheroes metadata"

  # Tags currently not supported
  # tags = local.tags
}

#--------------------------------------------------------------
# Crawlers
#--------------------------------------------------------------
resource "aws_glue_crawler" "superheroes_glue_crawler" {
  database_name = aws_glue_catalog_database.glue_catalog_database.name
  name          = "${var.project_prefix}-crawler"
  description   = "Responsible for crawling the S3 superheroes file and populating the glue catalog"
  role          = aws_iam_role.s3_glue_role.arn

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "LOG"
  }

    s3_target {
    path = "s3://${module.s3_athena_bucket.s3_bucket_id}/superheroes"
  }

  tags = local.tags
}

#--------------------------------------------------------------
# Jobs
#--------------------------------------------------------------
resource "aws_glue_job" "superheroes_job" {
  name        = "${var.project_prefix}-superheroes-job"
  role_arn    = aws_iam_role.s3_glue_role.arn
  description = "ETL job for superheroes data"

  glue_version      = "2.0"
  worker_type       = "G.1X"
  number_of_workers = var.glue_number_of_workers
  timeout           = 120

  command {
    name            = "glueetl"
    script_location = "s3://${module.s3_python_scripts_bucket.s3_bucket_id}/superheroes/superheroes.py"
    python_version  = 3
  }

  # AWS Data Wrangler is a Python module developed by AWS to extend the power of Pandas library.connection {
  # https://aws-data-wrangler.readthedocs.io/en/stable/index.html
  default_arguments = {
    "--additional-python-modules" = "pyarrow==2,awswrangler==2.4.0",
    "--class"                     = "GlueApp",
    "--job-language"              = "python",
    "--enable-job-insights"       = "false",
        # Glue env variables used by Python ETL
    "--catalog_database_name" = aws_glue_catalog_database.glue_catalog_database.name,
    "--catalog_table_name"    = "superheroes",
    "--curated_data_path"     = "s3://${module.s3_athena_bucket.s3_bucket_id}/query-results/"
  }

  tags = local.tags
}

#--------------------------------------------------------------
# Job Triggers
#--------------------------------------------------------------
// Triggring the superheroes Glue Crawler
resource "aws_glue_trigger" "superheroes_job_trigger" {
  name     = "${var.project_prefix}-superheroes-job-trigger"
  schedule = "cron(0 06 ? * MON-FRI *)" // At 06:00 AM, Monday through Friday
  type     = "SCHEDULED"

  actions {
    job_name = aws_glue_job.superheroes_job.name
  }
}

