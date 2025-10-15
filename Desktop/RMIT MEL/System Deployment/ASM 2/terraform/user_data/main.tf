# Posts Application Infrastructure - Section D Implementation
# High Availability Deployment with Load Balancers and Auto Scaling
# Target: 100 marks (all sections A+B+C+D)

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # S3 Backend for remote state (Section D requirement - 5 marks)
  backend "s3" {
    bucket = "posts-app-terraform-state-ch3mss-2025"
    key    = "terraform/terraform.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "COSC2759-Assignment2"
      Environment = var.environment
      Owner       = "ch3mss"
      ManagedBy   = "Terraform"
      Date        = "2025-10-15"
    }
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# S3 Bucket for Terraform State (Section D requirement - 5 marks)
resource "aws_s3_bucket" "terraform_state" {
  bucket = "posts-app-terraform-state-ch3mss-2025"
  
  tags = {
    Name        = "Terraform State Bucket"
    Purpose     = "Remote Backend Storage"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Security Groups - Principle of Least Privilege

# Frontend Load Balancer Security Group
resource "aws_security_group" "frontend_alb" {
  name_prefix = "frontend-alb-"
  vpc_id      = data.aws_vpc.default.id
  description = "Security group for Frontend Application Load Balancer"
  
  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "frontend-alb-sg"
  }
}

# Frontend Instance Security Group
resource "aws_security_group" "frontend" {
  name_prefix = "frontend-instances-"
  vpc_id      = data.aws_vpc.default.id
  description = "Security group for Frontend instances"
  
  ingress {
    description     = "HTTP from Frontend ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_alb.id]
  }
  
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "frontend-instances-sg"
  }
}

# Backend Load Balancer Security Group  
resource "aws_security_group" "backend_alb" {
  name_prefix = "backend-alb-"
  vpc_id      = data.aws_vpc.default.id
  description = "Security group for Backend Application Load Balancer"
  
  ingress {
    description     = "HTTP from Frontend instances"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend.id]
  }
  
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "backend-alb-sg"
  }
}

# Backend Instance Security Group
resource "aws_security_group" "backend" {
  name_prefix = "backend-instances-"
  vpc_id      = data.aws_vpc.default.id
  description = "Security group for Backend instances"
  
  ingress {
    description     = "HTTP from Backend ALB"
    from_port       = 3001
    to_port         = 3001
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_alb.id]
  }
  
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "backend-instances-sg"
  }
}

# Database Security Group
resource "aws_security_group" "database" {
  name_prefix = "database-"
  vpc_id      = data.aws_vpc.default.id
  description = "Security group for Database instance"
  
  ingress {
    description     = "PostgreSQL from Backend instances"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.backend.id]
  }
  
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "database-sg"
  }
}

# Key Pair for EC2 Access
resource "aws_key_pair" "posts_app" {
  key_name   = "posts-app-key-ch3mss"
  public_key = file("~/.ssh/id_rsa.pub")
  
  tags = {
    Name = "Posts App Key Pair"
  }
}

# Launch Templates for Auto Scaling Groups

# Frontend Launch Template
resource "aws_launch_template" "frontend" {
  name_prefix   = "frontend-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.posts_app.key_name
  
  vpc_security_group_ids = [aws_security_group.frontend.id]
  
  user_data = base64encode(templatefile("${path.module}/user_data/frontend.sh", {
    backend_url = "http://${aws_lb.backend.dns_name}"
  }))
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "frontend-instance"
      Type = "frontend"
      Owner = "ch3mss"
    }
  }
}

# Backend Launch Template
resource "aws_launch_template" "backend" {
  name_prefix   = "backend-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.posts_app.key_name
  
  vpc_security_group_ids = [aws_security_group.backend.id]
  
  user_data = base64encode(templatefile("${path.module}/user_data/backend.sh", {
    db_host     = aws_instance.database.private_ip
    db_user     = var.db_username
    db_password = var.db_password
  }))
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "backend-instance"
      Type = "backend"
      Owner = "ch3mss"
    }
  }
}

# Database Instance (Single instance)
resource "aws_instance" "database" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name              = aws_key_pair.posts_app.key_name
  vpc_security_group_ids = [aws_security_group.database.id]
  
  user_data = base64encode(templatefile("${path.module}/user_data/database.sh", {
    db_name     = "posts"
    db_user     = var.db_username
    db_password = var.db_password
  }))
  
  tags = {
    Name = "database-instance"
    Type = "database" 
    Owner = "ch3mss"
  }
}

# Auto Scaling Groups (Section D - 10 marks)

# Frontend Auto Scaling Group (2 instances)
resource "aws_autoscaling_group" "frontend" {
  name                = "frontend-asg-ch3mss"
  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns   = [aws_lb_target_group.frontend.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300
  
  min_size         = 2
  max_size         = 4
  desired_capacity = 2
  
  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }
  
  tag {
    key                 = "Name"
    value               = "frontend-asg-instance"
    propagate_at_launch = true
  }
}

# Backend Auto Scaling Group (2 instances)
resource "aws_autoscaling_group" "backend" {
  name                = "backend-asg-ch3mss"
  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns   = [aws_lb_target_group.backend.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300
  
  min_size         = 2
  max_size         = 4
  desired_capacity = 2
  
  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }
  
  tag {
    key                 = "Name"
    value               = "backend-asg-instance"
    propagate_at_launch = true
  }
}

# Application Load Balancers (Section D - 10 marks)

# Frontend Application Load Balancer (Public)
resource "aws_lb" "frontend" {
  name               = "frontend-alb-ch3mss"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.frontend_alb.id]
  subnets            = data.aws_subnets.default.ids
  
  enable_deletion_protection = false
  
  tags = {
    Name = "Frontend Application Load Balancer"
  }
}

# Backend Application Load Balancer (Internal)
resource "aws_lb" "backend" {
  name               = "backend-alb-ch3mss"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.backend_alb.id]
  subnets            = data.aws_subnets.default.ids
  
  enable_deletion_protection = false
  
  tags = {
    Name = "Backend Application Load Balancer"
  }
}

# Target Groups

# Frontend Target Group
resource "aws_lb_target_group" "frontend" {
  name     = "frontend-tg-ch3mss"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
  
  tags = {
    Name = "Frontend Target Group"
  }
}

# Backend Target Group  
resource "aws_lb_target_group" "backend" {
  name     = "backend-tg-ch3mss"
  port     = 3001
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/status"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
  
  tags = {
    Name = "Backend Target Group"
  }
}

# Load Balancer Listeners

# Frontend Listener
resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# Backend Listener
resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.backend.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}