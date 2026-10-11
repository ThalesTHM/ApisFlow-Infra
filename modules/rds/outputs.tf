output "address" {
  value = one(aws_db_instance.this[*].address)
}

output "port" {
  value = one(aws_db_instance.this[*].port)
}

output "db_name" {
  value = var.db_name
}

output "instance_id" {
  value = one(aws_db_instance.this[*].identifier)
}

output "secret_arns" {
  description = "ARNs dos segredos: database-url, migration-database-url, app-db-password"
  value       = { for k, s in aws_secretsmanager_secret.db : k => s.arn }
}
