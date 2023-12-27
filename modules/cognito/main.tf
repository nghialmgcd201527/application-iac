resource "aws_cognito_user_pool" "user_pool" {
  name                = "${var.project_name}-${var.stage}-userpool"
  username_attributes = ["email"]
  username_configuration {
    case_sensitive = false
  }
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  schema {
    name                     = "sub"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false
    required                 = false
    string_attribute_constraints {
      min_length = 1
      max_length = 2048
    }
  }
  schema {
    name                     = "name"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }
  # schema {
  #   name                     = "given_name"
  #   attribute_data_type      = "String"
  #   developer_only_attribute = false
  #   mutable                  = true
  #   required                 = true
  #   string_attribute_constraints {
  #     min_length = 0
  #     max_length = 2048
  #   }
  # }
  # schema {
  #   name                     = "family_name"
  #   attribute_data_type      = "String"
  #   developer_only_attribute = false
  #   mutable                  = true
  #   required                 = true
  #   string_attribute_constraints {
  #     min_length = 0
  #     max_length = 2048
  #   }
  # }
  schema {
    name                     = "middle_name"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }
  schema {
    name                     = "nickname"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }
  schema {
    name                     = "preferred_username"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }
  schema {
    name                     = "profile"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }
  schema {
    name                     = "picture"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }
  schema {
    name                     = "website"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }
  schema {
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }
  schema {
    name                     = "email_verified"
    attribute_data_type      = "Boolean"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
  }

  schema {
    name                     = "gender"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                     = "birthdate"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = 10
      max_length = 10
    }
  }
  schema {
    name                     = "zoneinfo"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }
  schema {
    name                     = "locale"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }
  schema {
    name                     = "phone_number"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }
  schema {
    name                     = "address"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                     = "updated_at"
    attribute_data_type      = "Number"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    number_attribute_constraints {
      min_value = 0
    }
  }

  schema {
    name                     = "account_type"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    name                     = "domain"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = 1
      max_length = 2048
    }
  }

  # schema {
  #   name                     = "user_type"
  #   attribute_data_type      = "String"
  #   developer_only_attribute = false
  #   mutable                  = true
  #   required                 = false
  #   string_attribute_constraints {
  #     min_length = 1
  #     max_length = 256
  #   }
  # }

  # schema {
  #   name                     = "city"
  #   attribute_data_type      = "String"
  #   developer_only_attribute = false
  #   mutable                  = true
  #   required                 = false
  #   string_attribute_constraints {
  #     min_length = 1
  #     max_length = 256
  #   }
  # }
  # schema {
  #   name                     = "state"
  #   attribute_data_type      = "String"
  #   developer_only_attribute = false
  #   mutable                  = true
  #   required                 = false
  #   string_attribute_constraints {
  #     min_length = 1
  #     max_length = 256
  #   }
  # }
  # schema {
  #   name                     = "zip_code"
  #   attribute_data_type      = "String"
  #   developer_only_attribute = false
  #   mutable                  = true
  #   required                 = false
  #   string_attribute_constraints {
  #     min_length = 1
  #     max_length = 256
  #   }
  # }

  password_policy {
    minimum_length                   = "8"
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }
  mfa_configuration = "OFF"
}


resource "aws_wafv2_web_acl" "main" {
  name  = "cognito-waf-${var.stage}"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "cognito-waf-${var.stage}"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl_association" "main" {
  resource_arn = aws_cognito_user_pool.user_pool.arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}


resource "aws_cognito_user_pool_client" "app_client" {
  name = "${var.project_name}-${var.stage}-userpoolappclient"

  user_pool_id          = aws_cognito_user_pool.user_pool.id
  access_token_validity = 60
  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
  "ALLOW_USER_SRP_AUTH"]
  id_token_validity = 60
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "lms${var.project_name}${var.stage}"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}


resource "aws_ssm_parameter" "app_client_id" {
  name  = "/global/${var.stage}/AWS_COGNITO_APP_CLIENT_ID"
  type  = "String"
  value = aws_cognito_user_pool_client.app_client.id

  tags = {
    environment = var.stage
  }
}

resource "aws_ssm_parameter" "user_pool_id" {
  name  = "/global/${var.stage}/AWS_COGNITO_USER_POOL_ID"
  type  = "String"
  value = aws_cognito_user_pool.user_pool.id

  tags = {
    environment = var.stage
  }
}
