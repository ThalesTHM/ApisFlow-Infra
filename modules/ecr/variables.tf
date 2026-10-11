variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "repositories" {
  description = "Nomes curtos dos repositórios (ex.: backend, frontend)"
  type        = list(string)
}

variable "max_images" {
  description = "Quantidade de imagens mantidas por repositório"
  type        = number
  default     = 20
}

variable "force_delete" {
  description = "Permite destruir o repositório mesmo com imagens"
  type        = bool
  default     = false
}
