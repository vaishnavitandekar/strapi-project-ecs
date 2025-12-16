output "alb_url" {
  value = aws_lb.alb.dns_name
}

output "ecr_repo" {
  value = aws_ecr_repository.this.repository_url
}
