resource "aws_ecr_repository" "this" {
  for_each = toset(var.repositories)

  name                 = "${var.project}-${var.environment}-${each.key}"
  image_tag_mutability = "IMMUTABLE" # tag = SHA do commit
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

# Mantém só as últimas imagens para não acumular custo de armazenamento.
resource "aws_ecr_lifecycle_policy" "this" {
  for_each = aws_ecr_repository.this

  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove imagens sem tag após 7 dias"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Mantém as últimas ${var.max_images} imagens"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.max_images
        }
        action = { type = "expire" }
      }
    ]
  })
}
