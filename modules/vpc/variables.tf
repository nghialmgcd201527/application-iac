variable "environment" {
  description = "the name of Environment"
  type        = string
  default     = ""
}
variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
}

variable "datacenter_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the datacenter subnet"
}

variable "thirdparty_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the thirdparty subnet"
}

variable "region" {
  description = "The region to launch the bastion host"
}

variable "availability_zones" {
  type        = list(any)
  description = "The az that the resources will be launched"
}
variable "az_shortname" {
  type        = list(any)
  description = "The az shortname"
}

variable "stage" {
  description = "Stage Name"
}

variable "project_name" {
  description = "Project Name"
  type        = string
}
variable "tooling_vpc_cidr" {
  description = "VPC CIDR of Tooling Account"
  type        = string
}

variable "ami" {
  description = "ami"
  type        = string
}
