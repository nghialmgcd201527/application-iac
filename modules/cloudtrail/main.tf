resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-cloudtrail-management-${var.stage}.trail"
  s3_bucket_name                = aws_s3_bucket.main.id
  include_global_service_events = false

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.main.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloud_trail.arn

  event_selector {
    read_write_type                  = "All"
    include_management_events        = true
    exclude_management_event_sources = ["rdsdata.amazonaws.com"]
  }

  depends_on = [aws_s3_bucket_policy.main]
}

resource "aws_cloudwatch_log_group" "main" {
  name = "${var.project_name}-aws-cloudtrail-logs-management-${var.stage}"
}

resource "aws_iam_role" "cloud_trail" {
  name               = "${var.project_name}-cloudtrail-logs-management-cloudwatch-role-${var.stage}"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "cloudtrail.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "main" {
  name = "cloudTrail-cloudWatch-policy"
  role = aws_iam_role.cloud_trail.id

  policy = <<POLICY
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Sid":"AWSCloudTrailCreateLogStream2014110",
         "Effect":"Allow",
         "Action":[
            "logs:CreateLogStream"
         ],
         "Resource":[
            "${aws_cloudwatch_log_group.main.arn}:*"
         ]
      },
      {
         "Sid":"AWSCloudTrailPutLogEvents20141101",
         "Effect":"Allow",
         "Action":[
            "logs:PutLogEvents"
         ],
         "Resource":[
            "${aws_cloudwatch_log_group.main.arn}:*"
         ]
      }
   ]
}
POLICY
}

resource "aws_s3_bucket" "main" {
  bucket        = "${var.project_name}-aws-cloudtrail-logs-management-${var.stage}"
  force_destroy = true
}

data "aws_iam_policy_document" "main" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.main.arn]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${var.project_name}-cloudtrail-management-${var.stage}.trail"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.main.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${var.project_name}-cloudtrail-management-${var.stage}.trail"]
    }
  }

}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.main.json
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}
