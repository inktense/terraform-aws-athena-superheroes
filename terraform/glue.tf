resource "aws_glue_catalog_database" "glue_catalog_database" {
  name        = "${var.project_prefix}-glue-catalog"
  description = "Glue catalog database responsible for storing superheroes metadata"

  # Tags currently not supported
  # tags = local.tags
}

# Adding Glue catalogue table because crawler does not detect file headers
# resource "aws_glue_catalog_table" "aws_glue_catalog_table" {
#   name          = "superheroes"
#   database_name = aws_glue_catalog_database.glue_catalog_database.name

#   table_type = "EXTERNAL_TABLE"

#   storage_descriptor {
#     location      = "s3://${module.s3_athena_bucket.s3_bucket_id}/superheroes-data"
#     # input_format  = "org.apache.hadoop.mapred.TextInputFormat"
#     # output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

#     # ser_de_info {
#     #   serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"

#     #   parameters = {
#     #     "serialization.format" = 1
#     #   }
#     # }

#     columns {
#       name = "name"
#       type = "string"
#     }

#     columns {
#       name = "gender"
#       type = "string"
#     }

#     columns {
#       name = "eye color"
#       type = "string"
#     }

#     columns {
#       name = "race"
#       type = "string"
#     }

#     columns {
#       name = "hair color"
#       type = "string"
#     }

#     columns {
#       name = "height"
#       type = "double"
#     }

#     columns {
#       name = "publisher"
#       type = "string"
#     }

#     columns {
#       name = "skin color"
#       type = "string"
#     }

#     columns {
#       name = "alignment"
#       type = "string"
#     }

#     columns {
#       name = "weight"
#       type = "double"
#     }

#   }
# }
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

  # catalog_target {
  #   database_name = aws_glue_catalog_database.glue_catalog_database.name
  #   tables        = [aws_glue_catalog_table.aws_glue_catalog_table.name]
  # }

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
