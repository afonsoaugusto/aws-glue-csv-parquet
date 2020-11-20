locals {
  tags = { "project" : var.project_name }
}

module "s3_bucket" {
  source         = "./modules/s3"
  s3_bucket_name = var.bucket_name
  tags           = local.tags
}

module "s3_object_load" {
  source       = "./modules/s3_object"
  s3_id        = module.s3_bucket.id
  key          = var.key_path_input
  path_to_file = var.path_input_file_load
  tags         = local.tags
}

module "s3_object_output_folder" {
  source = "./modules/s3_object"
  s3_id  = module.s3_bucket.id
  key    = var.key_path_output
  tags   = local.tags
}