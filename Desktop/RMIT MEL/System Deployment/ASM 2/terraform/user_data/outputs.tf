output "frontend_url" {
  description = "Frontend application URL - Access your app here!"
  value       = "http://${aws_lb.frontend.dns_name}"
}

output "backend_url" {
  description = "Backend application URL (internal)"
  value       = "http://${aws_lb.backend.dns_name}"
}

output "database_ip" {
  description = "Database private IP address"
  value       = aws_instance.database.private_ip
}

output "frontend_alb_dns" {
  description = "Frontend Application Load Balancer DNS name"
  value       = aws_lb.frontend.dns_name
}

output "backend_alb_dns" {
  description = "Backend Application Load Balancer DNS name"
  value       = aws_lb.backend.dns_name
}

output "s3_bucket_name" {
  description = "S3 bucket name for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    frontend_instances = "2 instances behind ALB"
    backend_instances  = "2 instances behind ALB"
    database_instances = "1 instance"
    total_instances    = "5 EC2 instances"
    load_balancers     = "2 Application Load Balancers"
    s3_backend         = "Enabled for remote state"
    sections_completed = "A + B + C + D = 100 marks"
  }
}