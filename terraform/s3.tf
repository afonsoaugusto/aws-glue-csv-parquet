module "s3_bucket_files" {
  source         = "./modules/s3"
  s3_bucket_name = var.bucket_name
  tags           = local.tags
}

module "s3_object_input_file" {
  source       = "./modules/s3_object"
  s3_id        = module.s3_bucket_files.id
  key          = var.key_path_input
  path_to_file = var.path_input_file_load
  tags         = local.tags
}

module "s3_object_output_folder" {
  source = "./modules/s3_object"
  s3_id  = module.s3_bucket_files.id
  key    = var.key_path_output
  tags   = local.tags
}

module "s3_bucket_scripts" {
  source         = "./modules/s3"
  s3_bucket_name = format("%s-%s", var.bucket_name, var.key_sufix_scripts)
  tags           = local.tags
}

module "s3_object_etl_script" {
  source       = "./modules/s3_object"
  s3_id        = module.s3_bucket_scripts.id
  key          = var.key_path_script
  path_to_file = var.path_script
  tags         = local.tags
}

module "s3_object_config_mapping" {
  source       = "./modules/s3_object"
  s3_id        = module.s3_bucket_scripts.id
  key          = var.key_path_config
  path_to_file = var.path_config
  tags         = local.tags
}

output "etl_script" {
  value = module.s3_object_etl_script.id
}

output "input_file" {
  value = module.s3_object_input_file.id
}

output "config_mapping" {
  value = module.s3_object_config_mapping.id
}

output "s3_bucket_scripts" {
  value = module.s3_bucket_scripts.id
}