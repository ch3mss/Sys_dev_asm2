variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "posts_user"
}

variable "db_password" {
  description = "Database password"
  type        = string
  default     = "SecurePassword123!"
  sensitive   = true
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "posts-app-ch3mss"
}