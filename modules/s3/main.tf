resource "aws_s3_bucket" "deploy_bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

# resource "aws_s3_bucket_website_configuration" "s3_web_config" {
#   bucket = aws_s3_bucket.deploy_bucket.bucket

# index_document {
#   suffix = "index.html"
# }

# error_document {
#   key = "error.html"
# }
# }

resource "aws_s3_bucket_public_access_block" "s3_access_block" {
  bucket = aws_s3_bucket.deploy_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}

resource "aws_s3_bucket_acl" "s3_acl_config" {
  bucket = aws_s3_bucket.deploy_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = aws_s3_bucket.deploy_bucket.id
  #   policy = data.aws_iam_policy_document.s3_policy.json
  policy = var.s3_policy
}