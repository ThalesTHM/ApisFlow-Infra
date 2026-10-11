output "vpc_id" {
  value = module.network.vpc_id
}

output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}

output "files_bucket" {
  value = module.s3.bucket_name
}

output "github_deploy_role_arn" {
  value = module.iam.github_deploy_role_arn
}

output "ecs_cluster" {
  value = module.ecs.cluster_name
}

output "alb_dns_name" {
  value = module.alb.dns_name
}

output "rds_address" {
  value = module.rds.address
}

output "redis_endpoint" {
  value = module.redis.primary_endpoint
}

output "alerts_topic_arn" {
  value = module.observability.alerts_topic_arn
}
