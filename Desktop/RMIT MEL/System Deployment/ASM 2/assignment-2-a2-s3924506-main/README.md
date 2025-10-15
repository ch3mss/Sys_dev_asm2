# COSC2759 Assignment 2 - Automated Deployment Solution

## Semester 2, 2025

## Executive Summary

This repository contains a comprehensive automated deployment solution for Yeetcode Inc.'s Posts application. The solution implements Infrastructure as Code (IaC) using Terraform, configuration management with Ansible, and CI/CD automation through GitHub Actions to deploy a three-tier web application on AWS EC2.

## Architecture Overview

The Posts application consists of three main components:

- **Frontend Service**: User interface for creating and viewing posts (EJS/Node.js)
- **Backend Service**: RESTful API for post management (Express.js)
- **Database Service**: PostgreSQL database with pre-applied migrations

### Available Docker Images

- `rmitdominichynes/sdo-2025:frontend`
- `rmitdominichynes/sdo-2025:backend`
- `rmitdominichynes/sdo-2025:db`

## Solution Components

### 1. Infrastructure Provisioning (Terraform)

- **EC2 Instances**: Scalable compute resources across multiple availability zones
- **Security Groups**: Network-level security with least-privilege access
- **Application Load Balancers**: High availability and traffic distribution
- **S3 Backend**: Remote state management for Terraform

### 2. Configuration Management (Ansible)

- **Docker Installation**: Automated container runtime setup
- **Service Deployment**: Containerized application deployment
- **Environment Configuration**: Secure environment variable management

### 3. CI/CD Pipeline (GitHub Actions)

- **Automated Deployment**: Trigger on main branch commits
- **Infrastructure Provisioning**: Terraform automation
- **Application Deployment**: Ansible playbook execution
- **Security**: No hardcoded credentials using GitHub Secrets

## Technical Decisions and Justifications

### 1. Container Technology Choice

**Decision**: Docker containers for all services  
**Justification**:

- Consistent runtime environment across development and production
- Simplified dependency management through pre-built images
- Easy horizontal scaling and version control
- Eliminates "works on my machine" issues

### 2. Infrastructure as Code (Terraform)

**Decision**: Terraform for infrastructure provisioning  
**Justification**:

- Declarative infrastructure definition ensures reproducibility
- State management enables safe infrastructure changes
- Version control for infrastructure changes
- Multi-cloud compatibility for future flexibility

### 3. Load Balancing Strategy (Section D Implementation)

**Decision**: Application Load Balancers (ALB) with Auto Scaling Groups  
**Justification**:

- **High Availability**: 5 EC2 instances (2 Frontend, 2 Backend, 1 Database)
- **Traffic Distribution**: Frontend ALB distributes public traffic, Backend ALB handles internal traffic
- **Fault Tolerance**: Health checks ensure traffic only goes to healthy instances
- **Scalability**: Auto Scaling Groups maintain desired capacity

### 4. Security Group Design

**Decision**: Principle of least privilege  
**Justification**:

- Frontend ALB: Only HTTP/HTTPS from internet (ports 80/443)
- Backend ALB: Only traffic from Frontend instances
- Database: Only PostgreSQL traffic from Backend (port 5432)
- Minimizes attack surface and follows AWS security best practices

### 5. Remote State Management (S3 Backend)

**Decision**: S3 bucket for Terraform state  
**Justification**:

- Enables team collaboration and prevents state conflicts
- State locking prevents concurrent modifications
- Versioning provides rollback capability
- Required for Section D (5 marks)

## High Availability Architecture (Section D - 100 Total Marks)

### Infrastructure Components

- **5 EC2 Instances**: 2x Frontend, 2x Backend, 1x Database
- **2 Application Load Balancers**: Frontend (public) and Backend (internal)
- **Auto Scaling Groups**: Automatic instance management
- **S3 Remote Backend**: Centralized state management

### Traffic Flow

1. **Internet** → **Frontend ALB** → **Frontend Instances**
2. **Frontend Instances** → **Backend ALB** → **Backend Instances**
3. **Backend Instances** → **Database Instance**

## Environment Variables and Configuration

### Frontend Service

| Variable    | Purpose              | Example                |
| ----------- | -------------------- | ---------------------- |
| PORT        | HTTP server port     | 3000                   |
| BACKEND_URL | Backend ALB endpoint | http://backend-alb-dns |

### Backend Service

| Variable    | Purpose             | Example            |
| ----------- | ------------------- | ------------------ |
| PORT        | HTTP server port    | 3001               |
| DB_HOST     | Database private IP | 10.0.1.100         |
| DB_USER     | Database username   | posts_user         |
| DB_PASSWORD | Database password   | SecurePassword123! |

### Database Service

| Variable          | Purpose           | Example            |
| ----------------- | ----------------- | ------------------ |
| POSTGRES_DB       | Database name     | posts              |
| POSTGRES_USER     | Database user     | posts_user         |
| POSTGRES_PASSWORD | Database password | SecurePassword123! |

## Deployment Instructions

### Prerequisites

1. **AWS Learner Lab**: Access with appropriate permissions
2. **GitHub Secrets**: AWS credentials configured
3. **SSH Keys**: Generated for EC2 access

### Automated Deployment (GitHub Actions)

1. Push changes to `main` branch
2. GitHub Actions workflow automatically:
   - Provisions infrastructure with Terraform
   - Deploys applications with Ansible
   - Provides application URLs

### Manual Deployment

```bash
# Configure AWS credentials
aws configure

# Deploy complete solution
./deploy.sh

# Verify deployment
./scripts/check-deployment.sh
```

## Deployment Status

✅ All AWS secrets configured  
✅ Ready for automated deployment  
📅 Deployment initiated: 2025-10-15
