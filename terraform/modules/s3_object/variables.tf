variable "s3_id" {
}

variable "s3_acl" {
  default = "private"
}

variable "source" {
  default = "/dev/null"
}

variable "s3_folders" {
  type    = list(string)
  default = ["folder1", "folder2", "folder3"]
}

variable "tags" {
  default = {}
}

