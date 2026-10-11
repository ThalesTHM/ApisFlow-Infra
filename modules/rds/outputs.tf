output "address" {
  value = one(aws_db_instance.this[*].address)
}

output "port" {
  value = one(aws_db_instance.this[*].port)
}

output "db_name" {
  value = var.db_name
}

output "master_secret_arn" {
  description = "Segredo (JSON com username/password) da senha master, gerenciado pelo RDS"
  value       = try(aws_db_instance.this[0].master_user_secret[0].secret_arn, null)
}

output "instance_id" {
  value = one(aws_db_instance.this[*].identifier)
}
