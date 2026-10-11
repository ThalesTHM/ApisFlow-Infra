output "primary_endpoint" {
  value = one(aws_elasticache_replication_group.this[*].primary_endpoint_address)
}

output "url_secret_arn" {
  value = one(aws_secretsmanager_secret.url[*].arn)
}

output "replication_group_id" {
  value = one(aws_elasticache_replication_group.this[*].replication_group_id)
}
