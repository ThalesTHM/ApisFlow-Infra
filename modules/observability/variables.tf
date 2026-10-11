variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "enabled" {
  description = "Cria alarmes e dashboard (só fazem sentido com os recursos ligados)"
  type        = bool
  default     = false
}

variable "alert_email" {
  description = "E-mail que recebe os alarmes. Vazio = sem inscrição"
  type        = string
  default     = ""
}

variable "alb_arn_suffix" {
  type    = string
  default = null
}

variable "ecs_cluster_name" {
  type = string
}

variable "rds_instance_id" {
  type    = string
  default = null
}

variable "redis_replication_group_id" {
  type    = string
  default = null
}
