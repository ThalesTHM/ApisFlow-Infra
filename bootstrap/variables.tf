variable "region" {
  description = "Região AWS do bucket de state"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Prefixo usado nos nomes dos recursos"
  type        = string
  default     = "apisflow"
}
