module "origin_bucket" {
  source                   = "terraform-aws-modules/s3-bucket/aws"
  bucket                   = var.bucket_name
  acl                      = "private"
  force_destroy            = var.is_force_destroy
  control_object_ownership = true
  object_ownership         = "ObjectWriter"
  block_public_acls        = true
  block_public_policy      = true
  ignore_public_acls       = true
  restrict_public_buckets  = true
  versioning = {
    enabled = var.is_bucket_versioning_enabled
  }
}

data "aws_iam_policy_document" "oac_policy" {
  version = "2008-10-17"
  statement {
    sid    = "AllowCloudFrontServicePrincipal"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = ["arn:aws:s3:::${var.bucket_name}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [module.cloudfront_with_oai.cloudfront_distribution_arn]
    }
  }
  statement {
    sid    = "AllowGetPutDeleteObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetObjectAcl",
      "s3:AbortMultipartUpload",
      "s3:PutObjectAcl",
    ]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:user/terraform_admin"]
    }
  }

  statement {
    sid       = "AllowListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.bucket_name}"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:user/terraform_admin"]
    }
  }
}


resource "aws_s3_bucket_website_configuration" "origin_bucket_site_config" {
  bucket = module.origin_bucket.s3_bucket_id
  index_document {
    suffix = "index.html"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = var.bucket_name
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_s3_bucket_policy" "origin_bucket_policy" {
  bucket = module.origin_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.oac_policy.json
}

locals {
  origin_access_control_key = "${var.bucket_name}-s3-oac"
}
# OAC
module "cloudfront_with_oai" {
  source              = "terraform-aws-modules/cloudfront/aws"
  comment             = "Cloudfront distribution with private S3 origin of ${var.bucket_name}"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"
  wait_for_deployment = false

  #OAC
  create_origin_access_control = true
  origin = {
    private_s3_origin = {
      domain_name           = module.origin_bucket.s3_bucket_bucket_regional_domain_name
      origin_access_control = local.origin_access_control_key
    }
  }
  origin_access_control = {
    "${local.origin_access_control_key}" = {
      description      = "cloud_origin_access_control_for_bucket",
      origin_type      = "s3",
      signing_behavior = "always",
      signing_protocol = "sigv4"
    }
  }

  default_cache_behavior = {
    target_origin_id       = "private_s3_origin" # key in `origin` above
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]

    compress             = true
    use_forwarded_values = false

    # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html#managed-cache-caching-optimized
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" // CachingOptimized
    # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-origin-request-policies.html
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" // CORS-S3Origin 
    # This is id for SecurityHeadersPolicy copied from https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-response-headers-policies.html
    response_headers_policy_id = "eaab4381-ed33-4a86-88ca-d9558dc6cd63" #CORS-with-preflight-and-SecurityHeadersPolicy
  }

  default_root_object = "index.html"
  custom_error_response = [{
    error_code         = 404
    response_code      = 404
    response_page_path = "/index.html"
    }, {
    error_code         = 403
    response_code      = 403
    response_page_path = "/index.html"
  }]
  viewer_certificate = {
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }

  aliases    = [var.domain_name]
  web_acl_id = var.waf_acl_id
}

resource "aws_route53_record" "cdn_alias" {
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = module.cloudfront_with_oai.cloudfront_distribution_domain_name
    zone_id                = module.cloudfront_with_oai.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }
}
