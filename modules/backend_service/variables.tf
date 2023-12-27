# General vars
variable "repo_name" {
  description = "Name of the repository."
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ECS Task Execution Role arn."
  type        = string
}

variable "stage" {
  description = "Stage name"
  type        = string
}
variable "region" {
  description = "Region"
  type        = string
  default     = "ap-southeast-1"
}
variable "environment" {
  description = "Name of environment"
  type        = string
}
variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository. Must be one of: `MUTABLE` or `IMMUTABLE`."
  type        = string
  default     = "MUTABLE"
}

variable "is_scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false)."
  type        = bool
  default     = true
}

variable "container_port" {
  description = "Container Port"
  type        = number
}

variable "container_cpu" {
  description = "Container CPU"
  type        = number
  default     = 1024
}

variable "container_memory" {
  description = "Container RAM"
  type        = number
  default     = 512
}
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
variable "private_security" {
  description = "SG"
  type        = list(any)
}
variable "private_subnets" {
  description = "Subnet"
  type        = list(any)
}
variable "routing_priority" {
  description = "Priority of routing"
  type        = string
}
variable "https_listener_arn" {
  description = "Target Group of listener"
  type        = string
}

variable "short_name" {
  description = "Shortname of service"
  type        = string
}

variable "project_name" {
}

variable "ecs_id" {
}
variable "ecs_cluster_name" {
}

variable "alarm_ecs_high_cpu_threshold" {
  description = "Max threshold average Memory percentage allowed in a 2 minutes interval (use 0 to disable this alarm)."
  default     = 85
}

variable "alarm_ecs_low_cpu_threshold" {
  description = "Min threshold average Memory percentage allowed in a 2 minutes interval (use 0 to disable this alarm)."
  default     = 10
}


variable "min_tasks" {
  default = 1
}

variable "max_tasks" {
  default = 3
}


variable "aws_account_id" {

}

variable "deployment_config_name" {
  default = "CodeDeployDefault.ECSAllAtOnce"
}
