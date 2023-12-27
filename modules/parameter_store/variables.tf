variable "stage" {
  type        = string
  description = "Stage Name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "region" {
  type        = string
  description = "AWS Region"
  default     = "ap-southeast-1"
}

variable "account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "tooling_account_id" {
  type        = string
  description = "AWS Tooling Account ID"
}

variable "timezone" {
  default = "Pacific/Honolulu"
}

variable "project_name" {
}

variable "api_url" {
}

variable "db_url_sensitive" {
  default = "sercret manage via rds"
}

variable "repo_name_list" {
  type = list(string)
}
