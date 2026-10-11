variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "account_id" {
  description = "Id da conta, para tornar o nome do bucket único"
  type        = string
}

variable "cors_allowed_origins" {
  description = "Origens do frontend autorizadas a usar URLs pré-assinadas"
  type        = list(string)
}
