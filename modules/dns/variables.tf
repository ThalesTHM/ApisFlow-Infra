variable "domain_name" {
  description = "Domínio do ambiente (ex.: homolog.apisflow.com.br). Vazio = sem DNS/HTTPS"
  type        = string
  default     = ""
}

variable "hosted_zone_name" {
  description = "Hosted zone existente no Route 53 (ex.: apisflow.com.br)"
  type        = string
  default     = ""
}

variable "alb_enabled" {
  type = bool
}

variable "alb_dns_name" {
  type    = string
  default = null
}

variable "alb_zone_id" {
  type    = string
  default = null
}
