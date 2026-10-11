# Domínio próprio (opcional): certificado ACM com wildcard, para identificar cada
# cooperativa por subdomínio, e registros no Route 53 apontando para o ALB.
# Requer uma hosted zone já existente no Route 53.

locals {
  enabled = var.domain_name != ""
}

data "aws_route53_zone" "this" {
  count = local.enabled ? 1 : 0

  name         = var.hosted_zone_name
  private_zone = false
}

resource "aws_acm_certificate" "this" {
  count = local.enabled ? 1 : 0

  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Domínio e wildcard geram o mesmo registro de validação (allow_overwrite).
resource "aws_route53_record" "validation" {
  for_each = local.enabled ? {
    for o in aws_acm_certificate.this[0].domain_validation_options : o.domain_name => o
  } : {}

  zone_id         = data.aws_route53_zone.this[0].zone_id
  name            = each.value.resource_record_name
  type            = each.value.resource_record_type
  records         = [each.value.resource_record_value]
  ttl             = 300
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "this" {
  count = local.enabled ? 1 : 0

  certificate_arn         = aws_acm_certificate.this[0].arn
  validation_record_fqdns = [for r in aws_route53_record.validation : r.fqdn]
}

resource "aws_route53_record" "alb" {
  for_each = local.enabled && var.alb_enabled ? toset([var.domain_name, "*.${var.domain_name}"]) : toset([])

  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = each.key
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
