variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "enabled" {
  description = "Cria o cluster (cobra por hora)"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "node_type" {
  type    = string
  default = "cache.t4g.micro"
}

variable "num_cache_clusters" {
  description = "1 em homologação; 2 (primário + réplica) em produção"
  type        = number
  default     = 1
}
