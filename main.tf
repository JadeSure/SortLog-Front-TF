locals {
  env_prefix = terraform.workspace
}


module "front-s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
  s3_policy   = data.aws_iam_policy_document.s3_policy.json
  env_prefix = local.env_prefix
}


module "front-cdn" {
  source          = "./modules/cdn"
  s3_origin_id    = var.s3_origin_id
  domain_name     = module.front-s3.s3_bucket.bucket_regional_domain_name
  cdn_comment     = var.cdn_comment
  my_domain_name  = var.my_domain_name
  acm_certificate = module.front-acm.acm_certificate
  env_prefix = local.env_prefix
  cdn_oai_comment = var.cdn_oai_comment
}


# for OAI updating policy
# Generates an IAM policy document in JSON format for use with resources that expect policy documents
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions = ["s3:GetObject"]
    # resources = ["${aws_s3_bucket.deploy_bucket.arn}/*"]
    resources = ["${module.front-s3.s3_bucket.arn}/*"]

    principals {
      type = "AWS"
      #   identifiers = [aws_cloudfront_origin_access_identity.cloudfront_oia.iam_arn]
      identifiers = [module.front-cdn.cloudfront_oia.iam_arn]
    }
  }
}

module "front-acm" {
  source         = "./modules/acm"
  my_domain_name = var.my_domain_name
  acm_region     = var.acm_region
  env_prefix = local.env_prefix
}


module "front-route53" {
  source                  = "./modules/route53"
  acm_certificate         = module.front-acm.acm_certificate
  my_domain_name          = var.my_domain_name
  acm_region              = var.acm_region
  cloudfront_distribution = module.front-cdn.cloudfront_distribution
  env_prefix = local.env_prefix
}
