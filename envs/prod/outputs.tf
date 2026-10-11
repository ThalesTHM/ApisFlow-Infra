output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "app_subnet_ids" {
  value = module.network.app_subnet_ids
}

output "data_subnet_ids" {
  value = module.network.data_subnet_ids
}

output "security_group_ids" {
  value = module.network.security_group_ids
}

output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}
