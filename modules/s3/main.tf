################################################################################################################
## Configure the bucket and static website hosting
################################################################################################################
# data "template_file" "bucket_policy_file" {
#   template = file("${path.module}/policy/website_bucket_policy.json")

#   vars = {
#     bucket = var.bucket_name
#   }
# }


resource "aws_s3_bucket" "main" {
  bucket        = var.bucket_name
  force_destroy = var.is_force_destroy
  tags = {
    Environment = var.environment
    Automation  = "Terraform"
  }
}
resource "aws_s3_bucket_cors_configuration" "main" {
  bucket = aws_s3_bucket.main.bucket

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


resource "aws_ssm_parameter" "s3_storage" {
  name  = "/global/${var.environment}/AWS_S3_USER_STORAGE_BUCKET"
  type  = "String"
  value = aws_s3_bucket.main.id

  tags = {
    environment = var.environment
  }
}
