output "cdn" {
  #   value = aws_cloudfront_distribution.s3_distribution.domain_name
  value = module.front-cdn.cloudfront_distribution.domain_name
}

output "front_domain_name" {
  value = var.my_domain_name
}