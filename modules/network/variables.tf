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

variable "single_nat" {
  description = "Usa um único NAT para todas as AZs em vez de um por AZ"
  type        = bool
  default     = true
}

variable "container_ports" {
  description = "Portas dos containers liberadas do ALB para o ECS"
  type        = list(number)
  default     = [3000, 80]
}
