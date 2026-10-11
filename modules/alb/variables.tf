variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "enabled" {
  description = "Cria o ALB (cobra por hora)"
  type        = bool
  default     = false
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "backend_port" {
  type    = number
  default = 3000
}

variable "frontend_port" {
  type    = number
  default = 80
}

variable "backend_health_path" {
  description = "Rota de health check do backend (o ALB só envia /api/* para ele)"
  type        = string
  default     = "/api/v1/health"
}

variable "certificate_arn" {
  description = "Certificado ACM. Vazio = só HTTP (sem domínio ainda)"
  type        = string
  default     = ""
}
