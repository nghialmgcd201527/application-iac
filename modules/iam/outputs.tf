output "cross_role_name" {
  value = aws_iam_role.cross_account_codebuild.name
}

output "cross_role_arn" {
  value = aws_iam_role.cross_account_codebuild.arn
}


output "ec2_role_name" {
  value = aws_iam_role.ec2_allow_ssm.name
}

output "ec2_role_arn" {
  value = aws_iam_role.ec2_allow_ssm.arn
}

output "ssm_role_arn" {
  value = aws_iam_role.ssmrole.arn
}
