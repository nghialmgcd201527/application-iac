# output "cdn_hostname" {
#   value = aws_cloudfront_distribution.website_cdn.domain_name
# }

output "cdn_id" {
  value = module.cloudfront_with_oai.cloudfront_distribution_id
}

# output "cdn_arn" {
#   value = aws_cloudfront_distribution.website_cdn.arn
# }

# output "cdn_zone_id" {
#   value = aws_cloudfront_distribution.website_cdn.hosted_zone_id
# }

output "bucket_id" {
  value = module.origin_bucket.s3_bucket_id
}

# output "bucket_arn" {
#   value = aws_s3_bucket.main.arn
# }

output "cloudfront_distribution_domain_name" {
  value = module.cloudfront_with_oai.cloudfront_distribution_domain_name
}

output "s3_bucket_bucket_domain_name" {
  value = module.origin_bucket.s3_bucket_bucket_domain_name
}
