output "state_bucket" {
  description = "Nome do bucket para usar no -backend-config dos ambientes"
  value       = aws_s3_bucket.state.bucket
}
