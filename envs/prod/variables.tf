variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "apisflow"
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "enabled" {
  description = "Liga os recursos que cobram por hora (NAT, ALB, RDS, Redis, Fargate)"
  type        = bool
  default     = false
}

variable "single_nat" {
  description = "Um único NAT (true) ou um por AZ (false)"
  type        = bool
  default     = true
}
