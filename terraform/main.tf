module "iam" {
  source     = "./modules/iam"
  name       = var.project_name
  buckets_s3 = [module.s3_bucket_scripts.id, module.s3_bucket_files.id]
  tags       = local.tags
}

resource "aws_glue_catalog_database" "glue_database" {
  name = var.project_name
}

resource "aws_glue_crawler" "example" {
  database_name = aws_glue_catalog_database.glue_database.name
  name          = var.project_name
  role          = module.iam.role_arn

  s3_target {
    path = format("s3://%s/%s", module.s3_bucket_files.id, module.s3_object_input_file.id)
  }
}

resource "aws_glue_job" "etl" {
  name              = var.project_name
  role_arn          = module.iam.role_arn
  max_retries       = 0
  timeout           = 5
  glue_version      = "2.0"
  worker_type       = "Standard"
  number_of_workers = 2

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = format("s3://%s/%s", module.s3_bucket_scripts.id, module.s3_object_etl_script.id)
  }

  default_arguments = {
    "--job-language"          = "python"
    "--ENV"                   = "env"
    "--spark-event-logs-path" = format("s3://%s", module.s3_bucket_files.id)
    "--job-bookmark-option"   = "job-bookmark-disable"
    "--enable-spark-ui"       = "false"
  }

  execution_property {
    max_concurrent_runs = 1
  }
}
