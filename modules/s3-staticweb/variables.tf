variable "region" {
  default = "ap-southeast-1"
}
variable "aws_account_id" {
}
variable "route53_zone_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket to create."
}
variable "is_bucket_versioning_enabled" {
  type        = string
  description = "Enable Versioning"
  default     = false
}

variable "acm_certificate_arn" {
  type = string
}

variable "routing_rules" {
  type    = string
  default = ""
}

variable "default_root_object" {
  type    = string
  default = "index.html"
}

variable "not_found_response_path" {
  type    = string
  default = "/index.html"
}

variable "not_found_response_code" {
  type    = string
  default = "400"
}

variable "tags" {
  type        = map(string)
  description = "Optional Tags"
  default     = {}
}

variable "is_forward_query_string" {
  type        = bool
  description = "Forward the query string to the origin"
  default     = false
}

variable "price_class" {
  type        = string
  description = "CloudFront price class"
  default     = "PriceClass_200"
}

variable "is_ipv6" {
  type        = bool
  description = "Enable IPv6 on CloudFront distribution"
  default     = false
}

variable "minimum_client_tls_protocol_version" {
  type        = string
  description = "CloudFront viewer certificate minimum protocol version"
  default     = "TLSv1"
}

variable "is_force_destroy" {
  type        = bool
  description = "A boolean that indicates all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  default     = false
}

variable "waf_acl_id" {
  description = "ARN of the WAF ACL"
}

variable "environment" {
  description = "the name of Environment"
  type        = string
  default     = ""
}
variable "locations" {
  type        = list(any)
  default     = ["US", "VN"]
  description = "Restrict access in contry zone"
}
