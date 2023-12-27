output "cognito_user_pool_id" {
  value       = aws_cognito_user_pool.user_pool.id
  description = "Cognito User Pool ID"
}


output "cognito_app_pool_id" {
  value       = aws_cognito_user_pool_client.app_client.id
  description = "Cognito App Client Pool ID"
}
