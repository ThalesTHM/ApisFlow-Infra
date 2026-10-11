output "task_execution_role_arn" {
  value = aws_iam_role.task_execution.arn
}

output "task_role_arn" {
  value = aws_iam_role.task.arn
}

output "github_deploy_role_arn" {
  value = aws_iam_role.github_deploy.arn
}

output "infra_ci_role_arn" {
  value = one(aws_iam_role.infra_ci[*].arn)
}
