################################################################################################################
## Create ACM with hosted in us-east-1 (required for cloudfront)
################################################################################################################
resource "aws_acm_certificate" "this" {
  // count = var.is_create_certificate ? 1 : 0
  provider                  = aws.us-east-1
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = var.validation_method

  options {
    certificate_transparency_logging_preference = var.is_certificate_transparency_logging_preference ? "ENABLED" : "DISABLED"
  }

  tags = {
    Name        = var.domain_name
    Environment = var.environment
    Automation  = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}


################################################################################################################
## Validate the ACM
################################################################################################################
// data "aws_route53_zone" "r53_zone" {
//   name         = var.domain_name
//   private_zone = false
// }
resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
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
  zone_id         = var.zone_id
  depends_on      = [aws_acm_certificate.this]
}

resource "aws_acm_certificate_validation" "this" {
  timeouts {
    create = "15m"
  }
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
  depends_on              = [aws_route53_record.validation]
}

################################################################################################################
## Create ACM with hosted in current region for API
################################################################################################################
resource "aws_acm_certificate" "api" {
  // count = var.is_create_certificate ? 1 : 0
  domain_name               = var.api_url
  subject_alternative_names = var.api_subject_alternative_names
  validation_method         = var.validation_method

  options {
    certificate_transparency_logging_preference = var.is_certificate_transparency_logging_preference ? "ENABLED" : "DISABLED"
  }

  tags = {
    Name        = var.api_url
    Environment = var.environment
    Automation  = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}


################################################################################################################
## Validate the ACM API
################################################################################################################
resource "aws_route53_record" "api_validation" {
  for_each = {
    for dvo in aws_acm_certificate.api.domain_validation_options : dvo.domain_name => {
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
  zone_id         = var.zone_id
  depends_on      = [aws_acm_certificate.api]
}

resource "aws_acm_certificate_validation" "api" {
  timeouts {
    create = "15m"
  }
  certificate_arn         = aws_acm_certificate.api.arn
  validation_record_fqdns = [for record in aws_route53_record.api_validation : record.fqdn]
  depends_on              = [aws_route53_record.api_validation]
}
