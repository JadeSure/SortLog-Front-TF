output "cloudfront_oia" {
  value = aws_cloudfront_origin_access_identity.cloudfront_oia
}

output "cloudfront_distribution" {
  value = aws_cloudfront_distribution.s3_distribution
}

