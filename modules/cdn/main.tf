locals {
  #   s3_origin_id = "sortLogS3Origin"
  s3_origin_id = var.s3_origin_id
}

# for OAI
resource "aws_cloudfront_origin_access_identity" "cloudfront_oia" {
  comment ="$(cdn_oai_comment)"
}



resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    # domain_name = module.front-s3.s3_bucket.bucket_regional_domain_name
    domain_name = var.domain_name
    origin_id   = local.s3_origin_id


    # for oai
    s3_origin_config {
      #  create an aws cloudfront OAI
      origin_access_identity = aws_cloudfront_origin_access_identity.cloudfront_oia.cloudfront_access_identity_path
    }
  }

  # If using route53 aliases for DNS we need to declare it here too, otherwise we'll get 403s.
  aliases = [var.my_domain_name]

  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.cdn_comment
  default_root_object = "index.html"

  #   logging_config {
  #     include_cookies = false
  #     bucket          = "mylogs.s3.amazonaws.com"
  #     prefix          = "myprefix"
  #   }

  #   aliases = ["mysite.example.com", "yoursite.example.com"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "AU"]
    }
  }

  # for https
  viewer_certificate {
    # cloudfront_default_certificate = true
    acm_certificate_arn      = var.acm_certificate.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}
