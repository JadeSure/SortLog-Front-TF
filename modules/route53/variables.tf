variable "acm_certificate" {}
variable "my_domain_name" {}
variable "acm_region" {}

variable "cloudfront_distribution" {}
variable "env_prefix" {}

# name = "${aws_cloudfront_distribution.cdn.domain_name}"
#     zone_id = "${aws_cloudfront_distribution.cdn.hosted_zone_id}"
