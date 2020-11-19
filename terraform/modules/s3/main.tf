resource "aws_s3_bucket" "this" {
  bucket = var.s3_bucket_name
  acl    = var.s3_acl

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = var.s3_versioning
  }

  tags = var.tags
}