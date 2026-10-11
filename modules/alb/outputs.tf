output "dns_name" {
  value = one(aws_lb.this[*].dns_name)
}

output "arn_suffix" {
  value = one(aws_lb.this[*].arn_suffix)
}

output "backend_target_group_arn" {
  value = one(aws_lb_target_group.backend[*].arn)
}

output "frontend_target_group_arn" {
  value = one(aws_lb_target_group.frontend[*].arn)
}

output "backend_target_group_arn_suffix" {
  value = one(aws_lb_target_group.backend[*].arn_suffix)
}

output "zone_id" {
  value = one(aws_lb.this[*].zone_id)
}
