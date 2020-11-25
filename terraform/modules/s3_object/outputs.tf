output "id" {
  value = aws_s3_bucket_object.this.id
}

output "etag" {
  value = aws_s3_bucket_object.this.etag
}

output "version_id" {
  value = aws_s3_bucket_object.this.version_id
}
