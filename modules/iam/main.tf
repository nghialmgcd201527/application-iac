data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.tooling_aws_account_id}:root"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "codebuild_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:ListRoleTags",
      "iam:TagRole",
      "iam:PutRolePermissionsBoundary",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:UpdateRoleDescription",
      "iam:ListRoles",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:AttachRolePolicy",
      "iam:PutRolePolicy",
      "iam:AddRoleToInstanceProfile",
      "iam:ListInstanceProfilesForRole",
      "iam:GetServiceLinkedRoleDeletionStatus",
      "iam:CreateServiceLinkedRole",
      "iam:ListAttachedRolePolicies",
      "iam:UpdateRole",
      "iam:DeleteServiceLinkedRole",
      "iam:ListRolePolicies",
      "iam:GetRolePolicy"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:CreateAlias",
      "kms:CreateKey",
      "kms:DeleteAlias",
      "kms:Describe*",
      "kms:GenerateRandom",
      "kms:Get*",
      "kms:List*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:PutKeyPolicy"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:List*",
      "s3:GetObject",
      "s3:PutObject",
      "logs:*"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "apigateway:*"
    ]
    resources = ["*"]
  }
}


resource "aws_iam_role" "cross_account_codebuild" {
  name               = "Cross-Account-Code-Build-Role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonCognitoPowerUser",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess",
    "arn:aws:iam::aws:policy/AWSLambda_FullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/IAMFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  ])
  role       = aws_iam_role.cross_account_codebuild.id
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "policy_attachment_additional" {
  role       = aws_iam_role.cross_account_codebuild.id
  policy_arn = aws_iam_policy.codebuild_policy.arn
}

resource "aws_iam_policy" "codebuild_policy" {
  name   = "codebuild_policy"
  policy = data.aws_iam_policy_document.codebuild_policy.json
}
data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2_allow_ssm" {
  name               = "Allow-SSM-EC2"
  description        = "Allows EC2 instances to call AWS services on your behalf."
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ec2_policy_attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ])
  role       = aws_iam_role.ec2_allow_ssm.id
  policy_arn = each.value
}
data "aws_iam_policy_document" "assume_by_codedeploy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "assume_by_codepipeline" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codedeploy" {
  name               = "CodeDeploy_ECS_Role"
  assume_role_policy = data.aws_iam_policy_document.assume_by_codedeploy.json
}

resource "aws_iam_role" "codepipeline" {
  name               = "CodePipeline_CodeDeploy_role"
  assume_role_policy = data.aws_iam_policy_document.assume_by_codepipeline.json
}

data "aws_iam_policy_document" "codedeploy" {
  statement {
    sid    = "AllowLoadBalancingAndECSModifications"
    effect = "Allow"

    actions = [
      "ecs:CreateTaskSet",
      "ecs:DeleteTaskSet",
      "ecs:DescribeServices",
      "ecs:UpdateServicePrimaryTaskSet",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyRule",
      "lambda:InvokeFunction",
      "cloudwatch:DescribeAlarms",
      "sns:Publish",
      "s3:GetObject",
      "s3:GetObjectMetadata",
      "s3:GetObjectVersion"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowPassRole"
    effect = "Allow"

    actions = ["iam:PassRole"]

    resources = [
      "arn:aws:iam::${var.aws_account_id}:role/ECSTaskRole",
      "arn:aws:iam::${var.aws_account_id}:role/ECSTaskExecutionRole-Fargate",
    ]
  }
}

resource "aws_iam_role_policy" "codedeploy" {
  role   = aws_iam_role.codedeploy.name
  policy = data.aws_iam_policy_document.codedeploy.json
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    actions = [
      "iam:PassRole"
    ]
    resources = ["*"]
    effect    = "Allow"
    condition {
      test = "StringEqualsIfExists"
      values = [
        "cloudformation.amazonaws.com",
        "elasticbeanstalk.amazonaws.com",
        "ec2.amazonaws.com",
        "ecs-tasks.amazonaws.com"
      ]
      variable = "iam:PassedToService"
    }
  }

  statement {
    actions = [
      "codecommit:CancelUploadArchive",
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:GetRepository",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:UploadArchive"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "codestar-connections:UseConnection"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "elasticbeanstalk:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "s3:*",
      "sns:*",
      "cloudformation:*",
      "rds:*",
      "sqs:*",
      "ecs:*"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "lambda:InvokeFunction",
      "lambda:ListFunctions"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "opsworks:CreateDeployment",
      "opsworks:DescribeApps",
      "opsworks:DescribeCommands",
      "opsworks:DescribeDeployments",
      "opsworks:DescribeInstances",
      "opsworks:DescribeStacks",
      "opsworks:UpdateApp",
      "opsworks:UpdateStack"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "cloudformation:CreateStack",
      "cloudformation:DeleteStack",
      "cloudformation:DescribeStacks",
      "cloudformation:UpdateStack",
      "cloudformation:CreateChangeSet",
      "cloudformation:DeleteChangeSet",
      "cloudformation:DescribeChangeSet",
      "cloudformation:ExecuteChangeSet",
      "cloudformation:SetStackPolicy",
      "cloudformation:ValidateTemplate"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:BatchGetBuildBatches",
      "codebuild:StartBuildBatch"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "devicefarm:ListProjects",
      "devicefarm:ListDevicePools",
      "devicefarm:GetRun",
      "devicefarm:GetUpload",
      "devicefarm:CreateUpload",
      "devicefarm:ScheduleRun"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "servicecatalog:ListProvisioningArtifacts",
      "servicecatalog:CreateProvisioningArtifact",
      "servicecatalog:DescribeProvisioningArtifact",
      "servicecatalog:DeleteProvisioningArtifact",
      "servicecatalog:UpdateProduct"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "cloudformation:ValidateTemplate"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "ecr:DescribeImages"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "states:DescribeExecution",
      "states:DescribeStateMachine",
      "states:StartExecution"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "appconfig:StartDeployment",
      "appconfig:StopDeployment",
      "appconfig:GetDeployment"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_role_policy" "codepipeline" {
  role   = aws_iam_role.codepipeline.name
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

#create ssm role 

resource "aws_iam_role_policy" "ssmrole" {
  role   = aws_iam_role.ssmrole.name
  policy = data.aws_iam_policy_document.ssmrole.json
}

data "aws_iam_policy_document" "ssmrole" {
  statement {
    sid    = "Allowec2startsessionconnectdb"
    effect = "Allow"

    actions = [
      "ec2:*", "ssm:StartSession"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ssm:*"
    ]
    resources = ["arn:aws:ssm:*:*:*"]
    effect    = "Allow"
  }
}

resource "aws_iam_role" "ssmrole" {
  name               = "ssm-cross-account-${var.stage}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

# # Application apply for dev
# data "aws_iam_policy_document" "application_role" {
#   version = "2012-10-17"
#   statement {
#     effect = "Allow"
#     actions = [
#       "ecs:GetTaskProtection",
#       "ecs:ListAccountSettings",
#       "ecs:DescribeCapacityProviders",
#       "ecs:ListTagsForResource",
#       "ecs:DescribeServices",
#       "ecs:DescribeTaskSets",
#       "ecs:DescribeContainerInstances",
#       "ecs:DescribeTasks",
#       "ecs:DescribeTaskDefinition",
#       "ecs:DescribeClusters",
#       "ecs:ListClusters",
#       "ecs:ListServices",
#       "ecs:List*"
#     ]
#     resources = ["*"]
#   }
# }


# resource "aws_iam_role" "application_role" {
#   name               = "Application-${var.stage}-role"
#   assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
# }

# resource "aws_iam_role_policy_attachment" "application_policy_attachment" {
#   for_each = toset([
#     "arn:aws:iam::aws:policy/AmazonCognitoPowerUser",
#     "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
#     "arn:aws:iam::aws:policy/AmazonESCognitoAccess",
#     "arn:aws:iam::aws:policy/AWSLambda_FullAccess",
#     "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess",
#     "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
#     "arn:aws:iam::aws:policy/AmazonSNSFullAccess",
#     "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
#     "arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess"
#   ])
#   role       = aws_iam_role.application_role.id
#   policy_arn = each.value
# }

# resource "aws_iam_role_policy_attachment" "application_policy_attachment_additional" {
#   role       = aws_iam_role.application_role.id
#   policy_arn = aws_iam_policy.application_policy.arn
# }

# resource "aws_iam_policy" "application_policy" {
#   name   = "ecs-read-onlyaccess"
#   policy = data.aws_iam_policy_document.application_role.json
# }
