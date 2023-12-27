variable "project_name" {
  description = "Name of project"
}

variable "service_name" {
  description = "Name of service"
}

variable "stage" {
  description = "Name of stage"
}
variable "is_sns_enabled" {
  description = "Include SNS is modules or not ?"
  default     = true
  type        = bool
}
variable "is_encrypted" {
  description = "Is SQS encrypted or not ?"
  type        = bool
}
