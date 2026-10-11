variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  description = "Bloco CIDR da VPC (/16)"
  type        = string
}

variable "az_count" {
  description = "Quantidade de zonas de disponibilidade usadas"
  type        = number
  default     = 2
}

variable "enable_nat" {
  description = "Cria o NAT Gateway (cobra por hora)"
  type        = bool
  default     = false
}
