
variable "project_name" {
  description = "Project Name for use"
}

variable "bucket_name" {
  description = "Bucket_Name"
}

variable "key_path_input" {}

variable "path_input_file_load" {}

variable "key_path_output" {}

variable "key_sufix_scripts" {}

variable "key_path_script" {}

variable "path_script" {}

variable "key_path_config" {}

variable "path_config" {}

locals {
  tags = { "project" : var.project_name }
}
