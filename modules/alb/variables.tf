variable "project_name" {
  type        = string
  description = "The name of the project"
}

variable "stage" {
  type        = string
  description = "Stage name"
}
variable "availability_zones" {
  type        = list(string)
  description = "Availability zones"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "route53_zone_id" {
  type        = string
  description = "R53 zone ID"
}

variable "api_url" {
  type        = string
  description = "URL of API service"
}


variable "environment" {
  type        = string
  description = "Environment name"
}

variable "security_groups" {
  type        = list(string)
  description = "Private SG IDs"
}


variable "public_subnet_ids" {
  type        = list(any)
  description = "Public Subnet IDs"
}

variable "api_acm_certificate_arn" {
  type        = string
  description = "API ACM Certificate ARN"
}
variable "acm_certificate_arn" {
  type        = string
  description = "API ACM Certificate ARN"
}
variable "ssl_policy_name" {
  type        = string
  description = "SSL Policy name"
  default     = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
}
variable "alarm_alb_500_errors_threshold" {
  description = "Max threshold of HTTP 500 errors allowed in a 5 minutes interval (use 0 to disable this alarm)."
  default     = 10
}
variable "alarm_alb_400_errors_threshold" {
  description = "Max threshold of HTTP 400 errors allowed in a 5 minutes interval (use 0 to disable this alarm)."
  default     = 10
}


variable "ops_email_address" {
  description = "Email to notification on alarm"
  type        = string
  default     = "dhasysadmin@datahouse.com"
}


variable "alarm_alb_latency_anomaly_threshold" {
  description = "ALB Latency anomaly detection width (use 0 to disable this alarm)."
  default     = 2
}

variable "api_gw_ids" {
  type        = list(any)
  description = "List of API Gateway ID"
}
