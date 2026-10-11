output "task_execution_role_arn" {
  value = aws_iam_role.task_execution.arn
}

output "task_role_arn" {
  value = aws_iam_role.task.arn
}

output "github_deploy_role_arn" {
  value = aws_iam_role.github_deploy.arn
}
