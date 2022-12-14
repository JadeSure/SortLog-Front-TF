# resource "aws_route53_zone" "hosted_zone" {
#   name = "shawnwong.click"
# }
locals {
  my_domain_name = var.my_domain_name
}

provider "aws" {
  region = var.acm_region
  alias  = "Virginia"
}
data "aws_route53_zone" "route53_zone" {
  name         = local.my_domain_name
  private_zone = false
}

resource "aws_route53_record" "root_domain" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = var.my_domain_name
  type    = "A"

  alias {
    # name = "${aws_cloudfront_distribution.cdn.domain_name}"
    name = var.cloudfront_distribution.domain_name
    # zone_id = "${aws_cloudfront_distribution.cdn.hosted_zone_id}"
    zone_id                = var.cloudfront_distribution.hosted_zone_id
    evaluate_target_health = false
  }


}


# resource "aws_route53_record" "www" {
#   zone_id = aws_route53_zone.route53_zone.zone_id
#   name    = "sortlog.shawnwong.click"
#   type    = "A"
#   ttl     = 300
#   records = [aws_eip.lb.public_ip]
# }

resource "aws_route53_record" "route53_record" {
  for_each = {
    # when request a public certificate, aws certifiate manager will give us a CNAME => create a record set in route53
    for dvo in var.acm_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.route53_zone.zone_id
}


# validate acm certificates
resource "aws_acm_certificate_validation" "acm_certificate_validation" {
  provider                = aws.Virginia
  certificate_arn         = var.acm_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.route53_record : record.fqdn]
}