data "aws_region" "current" {}

resource "aws_s3_bucket" "main" {
  bucket        = "${var.project_name}-${var.stage}-alb-log"
  force_destroy = true

  tags = {
    Environment = "${var.environment}"
    Name        = "${var.project_name}-${var.stage}-alb-log"
  }
}
resource "aws_lb" "public" {
  name                       = "${var.project_name}-${var.stage}-api-elb"
  internal                   = false
  load_balancer_type         = "application"
  idle_timeout               = "60"
  security_groups            = var.security_groups
  drop_invalid_header_fields = false
  subnets = flatten([
    var.public_subnet_ids
  ])
  //https://www.terraform.io/language/upgrade-guides/0-12#referring-to-list-variables
  enable_deletion_protection = true
  ip_address_type            = "ipv4"
  # access_logs {
  #   bucket  = "${var.project_name}-${var.stage}-alb-log"
  #   prefix  = "access.log"
  #   enabled = true
  # }
  tags = {
    Environment = "${var.environment}"
    Name        = "${var.project_name}-${var.stage}-api-elb"
  }
}

#######################
# Create Listener Rule
#######################

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.public.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }

  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.public.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy_name
  certificate_arn   = var.api_acm_certificate_arn
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "503"
    }
  }
}

# Create a CloudFront distribution
resource "aws_cloudfront_origin_access_identity" "alb_public" {
  comment = "ALB-CF-OAI"
}

resource "aws_cloudfront_distribution" "alb_public" {
  aliases    = ["${var.api_url}"]
  depends_on = [aws_wafv2_web_acl.apialbwafacl]
  web_acl_id = aws_wafv2_web_acl.apialbwafacl.arn

  origin {
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
    domain_name = aws_lb.public.dns_name
    origin_id   = aws_lb.public.dns_name
  }

  dynamic "origin" {

    for_each = var.api_gw_ids

    content {

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
      domain_name = "${origin.value.id}.execute-api.${data.aws_region.current.name}.amazonaws.com"
      origin_id   = "origin_${origin.value.id}"
      origin_path = "/${origin.value.stage}"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  enabled = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "DELETE", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = aws_lb.public.dns_name #expect to change to OAI

    forwarded_values {
      query_string = true
      headers      = ["Authorization", "Host", "CloudFront-Viewer-Time-Zone", "CloudFront-Viewer-Country-Region-Name", "CloudFront-Viewer-Country-Name", "CloudFront-Viewer-City", "CloudFront-Viewer-Latitude", "CloudFront-Viewer-Longitude", "User-Agent"] #Change from Origin to Host
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.api_gw_ids

    content {
      allowed_methods  = ["GET", "HEAD", "OPTIONS", "DELETE", "PATCH", "POST", "PUT"]
      cached_methods   = ["GET", "HEAD", "OPTIONS"]
      target_origin_id = "origin_${ordered_cache_behavior.value.id}"

      cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" // CachingDisabled https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html
      origin_request_policy_id   = "b689b0a8-53d0-40ab-baf2-68738e2966ac" // AllViewerExceptHostHeader https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-origin-request-policies.html
      response_headers_policy_id = "eaab4381-ed33-4a86-88ca-d9558dc6cd63" // CORS-with-preflight-and-SecurityHeadersPolicy https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-response-headers-policies.html

      path_pattern           = "/${ordered_cache_behavior.value.path}/*"
      viewer_protocol_policy = "redirect-to-https"
    }
  }
}

# Create a WAF
resource "aws_wafv2_web_acl" "apialbwafacl" {
  provider = aws.us-east-1
  name     = "${var.project_name}-api-${var.stage}-wafacl"
  scope    = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-api-${var.stage}-waf"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "CORS-Permit"
    priority = 7

    action {
      allow {}
    }

    statement {
      byte_match_statement {
        field_to_match {
          single_header {
            name = "origin"
          }
        }
        positional_constraint = "ENDS_WITH"
        search_string         = var.api_url
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CORS-Permit"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "LambdaCall-Permit"
    priority = 6

    action {
      allow {}
    }

    statement {
      byte_match_statement {
        field_to_match {
          single_header { name = "origin" } #change from uri_path to single_header
        }
        positional_constraint = "CONTAINS"
        search_string         = "lambda"
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "LambdaCall-Permit"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "AWSManagedRulesLinuxRuleSet"
    priority = 8
    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesLinuxRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesAnonymousIpList"
    priority = 5
    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAnonymousIpList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 4
    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesAdminProtectionRuleSet"
    priority = 3
    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAdminProtectionRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAdminProtectionRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 2
    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 1
    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }
}

######################################
# Create A Record for load balancer
######################################

resource "aws_route53_record" "cdn_alias" {
  zone_id = var.route53_zone_id
  name    = var.api_url
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.alb_public.domain_name
    zone_id                = aws_cloudfront_distribution.alb_public.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  provider = aws.us-east-1
  name     = "aws-waf-logs-alb-api"

  tags = {
    Environment = "${var.stage}"
    Application = "API"
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "main" {
  provider                = aws.us-east-1
  log_destination_configs = [aws_cloudwatch_log_group.log_group.arn]
  resource_arn            = aws_wafv2_web_acl.apialbwafacl.arn
  redacted_fields {
    method {
    }
  }
}

resource "aws_sns_topic" "api_sns_alarm" {
  name            = "${var.project_name}-${var.stage}-api-sns-alarms"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false
  }
}
EOF
}


# resource "aws_sns_topic_subscription" "api_sns_alarm" {
#   topic_arn = aws_sns_topic.api_sns_alarm.arn
#   protocol  = "email"
#   endpoint  = var.ops_email_address
# }


resource "aws_cloudwatch_metric_alarm" "alb_500_errors" {
  alarm_name                = "${var.project_name}-${var.stage}-alb-500-errors"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "HTTPCode_ELB_5XX_Count"
  namespace                 = "AWS/ApplicationELB"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = var.alarm_alb_500_errors_threshold
  alarm_description         = "Number of 500 errors at ALB above threshold"
  alarm_actions             = [aws_sns_topic.api_sns_alarm.arn]
  ok_actions                = [aws_sns_topic.api_sns_alarm.arn]
  insufficient_data_actions = []
  treat_missing_data        = "ignore"

  dimensions = {
    LoadBalancer = aws_lb.public.arn
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_400_errors" {
  alarm_name                = "${var.project_name}-${var.stage}-alb-400-errors"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "HTTPCode_ELB_4XX_Count"
  namespace                 = "AWS/ApplicationELB"
  period                    = "300"
  statistic                 = "Maximum"
  threshold                 = var.alarm_alb_400_errors_threshold
  alarm_description         = "Number of 400 errors at ALB above threshold"
  alarm_actions             = [aws_sns_topic.api_sns_alarm.arn]
  ok_actions                = [aws_sns_topic.api_sns_alarm.arn]
  insufficient_data_actions = []
  treat_missing_data        = "ignore"

  dimensions = {
    LoadBalancer = aws_lb.public.arn
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_latency" {
  alarm_name                = "${var.project_name}-${var.stage}-alb-latency"
  comparison_operator       = "GreaterThanUpperThreshold"
  evaluation_periods        = "2"
  datapoints_to_alarm       = "1"
  threshold_metric_id       = "ad1"
  alarm_description         = "Load balancer latency for application"
  alarm_actions             = [aws_sns_topic.api_sns_alarm.arn]
  ok_actions                = [aws_sns_topic.api_sns_alarm.arn]
  insufficient_data_actions = []
  treat_missing_data        = "ignore"

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1, ${var.alarm_alb_latency_anomaly_threshold})"
    label       = "TargetResponseTime (Expected)"
    return_data = "true"
  }
  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "TargetResponseTime"
      namespace   = "AWS/ApplicationELB"
      period      = "900"
      stat        = "p90"

      dimensions = {
        LoadBalancer = aws_lb.public.arn
      }
    }
  }
}

