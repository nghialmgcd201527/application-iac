variable "region" {
  default = "ap-southeast-1"
}
variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket to create."
}

variable "is_force_destroy" {
  type        = bool
  description = "A boolean that indicates all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  default     = false
}

variable "environment" {
  description = "the name of Environment"
  type        = string
  default     = ""
}
