module "s3_athena_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${var.project_prefix}-bucket"
  # Access control lists enable you to manage access to buckets and objects. 
  acl = "private"

  versioning = {
    enabled = true
  }

  # Enable S3 SSE  
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule = [
    {
      id     = "expiration_rule"
      status = "Enabled"

      noncurrent_version_expiration = {
        noncurrent_days = 30
      }
    }
  ]

  tags = local.tags
}

module "s3_python_scripts_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${var.project_prefix}-python-bucket"
  # Access control lists enable you to manage access to buckets and objects. 
  acl = "private"

  versioning = {
    enabled = true
  }

  # Enable S3 SSE  
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule = [
    {
      id     = "expiration_rule"
      status = "Enabled"

      noncurrent_version_expiration = {
        noncurrent_days = 30
      }
    }
  ]

  tags = local.tags
}

# Adding csv file to bucket
resource "aws_s3_object" "superheroes" {
  key                    = "superheroes/superheroes-data.csv"
  bucket                 = module.s3_athena_bucket.s3_bucket_id
  source                 = "../assets/heroes_information.csv"
  server_side_encryption = "AES256"
}


resource "aws_s3_object" "python_script" {
  key                    = "superheroes/superheroes.py"
  bucket                 = module.s3_python_scripts_bucket.s3_bucket_id
  source                 = "../assets/python_scripts/superheroes.py"
  server_side_encryption = "AES256"
}
