resource "aws_s3_bucket_object" "s3_object" {
  bucket = var.s3_id
  acl    = var.s3_acl
  key    = var.key
  source = var.path_to_file
  tags   = var.tags
  etag   = filemd5(var.path_to_file)
}
