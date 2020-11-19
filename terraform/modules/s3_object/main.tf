resource "aws_s3_bucket_object" "folders" {
  count  = length(var.s3_folders)
  bucket = var.s3_id
  acl    = var.acl
  key    = "${var.s3_folders[count.index]}/"
  source = var.source
}
