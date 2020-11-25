data "template_file" "assume_role" {
  template = "${file("${path.module}/assume_role.json.tpl")}"
}

resource "aws_iam_role" "role" {
  name               = format("%s-role", var.name)
  assume_role_policy = data.template_file.assume_role.rendered
  tags               = var.tags
}

locals {
  buckets_json_formated = jsonencode(formatlist("arn:aws:s3:::%s/*", var.buckets_s3))
}

data "template_file" "policy" {
  template = "${file("${path.module}/policy.json.tpl")}"
  vars = {
    buckets_json_formated = local.buckets_json_formated
  }
}

resource "aws_iam_role_policy" "iam_policy" {
  name   = format("%s-policy", var.name)
  role   = aws_iam_role.role.id
  policy = data.template_file.policy.rendered
}
