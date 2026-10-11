output "certificate_arn" {
  description = "Certificado já validado, ou vazio sem domínio"
  value       = local.enabled ? aws_acm_certificate_validation.this[0].certificate_arn : ""
}

output "url" {
  value = local.enabled ? "https://${var.domain_name}" : ""
}
