variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "enabled" {
  description = "Cria a instância (cobra por hora)"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "Sub-redes da camada de dados"
  type        = list(string)
}

variable "security_group_id" {
  type = string
}

variable "db_name" {
  type    = string
  default = "honey_manager"
}

variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "max_allocated_storage" {
  type    = number
  default = 50
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "backup_retention_days" {
  type    = number
  default = 7
}

variable "owner_username" {
  description = "Usuário mestre, dono das tabelas (migrações)"
  type        = string
  default     = "app_owner"
}

variable "app_username" {
  description = "Papel usado pela aplicação (sem BYPASSRLS)"
  type        = string
  default     = "app_user"
}

variable "deletion_protection" {
  type    = bool
  default = false
}
