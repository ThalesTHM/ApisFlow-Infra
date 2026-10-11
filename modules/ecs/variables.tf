variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "enabled" {
  description = "Cria task definitions e services (Fargate cobra por hora)"
  type        = bool
  default     = false
}

variable "app_subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "task_execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "backend_target_group_arn" {
  type    = string
  default = null
}

variable "frontend_target_group_arn" {
  type    = string
  default = null
}

# Imagem de teste até o CI/CD publicar as imagens reais no ECR.
variable "backend_image" {
  type    = string
  default = "public.ecr.aws/nginx/nginx:stable"
}

variable "frontend_image" {
  type    = string
  default = "public.ecr.aws/nginx/nginx:stable"
}

variable "backend_port" {
  type    = number
  default = 3000
}

variable "frontend_port" {
  type    = number
  default = 80
}

variable "backend_cpu" {
  type    = number
  default = 256
}

variable "backend_memory" {
  type    = number
  default = 512
}

variable "frontend_cpu" {
  type    = number
  default = 256
}

variable "frontend_memory" {
  type    = number
  default = 512
}

variable "backend_desired_count" {
  type    = number
  default = 1
}

variable "frontend_desired_count" {
  type    = number
  default = 1
}

variable "backend_max_count" {
  type    = number
  default = 4
}

variable "enable_autoscaling" {
  type    = bool
  default = false
}

variable "log_retention_days" {
  type    = number
  default = 14
}

variable "database_url_secret_arn" {
  type    = string
  default = null
}

variable "migration_database_url_secret_arn" {
  type    = string
  default = null
}

variable "app_db_password_secret_arn" {
  type    = string
  default = null
}

variable "redis_url_secret_arn" {
  type    = string
  default = null
}

variable "migrate_image" {
  description = "Imagem com o Prisma CLI (estágio build do Dockerfile do backend)"
  type        = string
  default     = "public.ecr.aws/docker/library/node:20-alpine"
}

variable "frontend_api_url" {
  description = "URL da API vista pelo navegador; relativa porque o ALB serve /api/*"
  type        = string
  default     = "/api/v1"
}

variable "files_bucket_name" {
  type = string
}

variable "cors_origin" {
  type = string
}

variable "swagger_enabled" {
  type    = bool
  default = false
}
