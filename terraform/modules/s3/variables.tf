variable "s3_bucket_name" {
}

variable "s3_acl" {
  default = "private"
}

variable "s3_versioning" {
  default = false
}

variable "tags" {
  default = {}
}