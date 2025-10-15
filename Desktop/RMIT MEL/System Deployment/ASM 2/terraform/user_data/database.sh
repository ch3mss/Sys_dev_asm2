#!/bin/bash

# Database Instance Setup - Section A (20 marks)
# Sets up PostgreSQL database container on port 5432

echo "Starting database setup at $(date)"

# Update system and install Docker
yum update -y
yum install -y docker

# Start Docker service
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Wait for Docker to be ready
sleep 15

# Pull the database image
echo "Pulling database image..."
docker pull rmitdominichynes/sdo-2025:db

# Create PostgreSQL data directory
mkdir -p /var/lib/postgresql/data
chown ec2-user:ec2-user /var/lib/postgresql/data

# Create environment file for database
cat > /tmp/database.env << EOF
POSTGRES_DB=${db_name}
POSTGRES_USER=${db_user}
POSTGRES_PASSWORD=${db_password}
POSTGRES_HOST_AUTH_METHOD=md5
EOF

# Run database container on port 5432 (as required by Section A)
echo "Starting PostgreSQL database container..."
docker run -d \
  --name database \
  --restart always \
  -p 5432:5432 \
  --env-file /tmp/database.env \
  -v /var/lib/postgresql/data:/var/lib/postgresql/data \
  rmitdominichynes/sdo-2025:db

# Wait and verify database is running
sleep 10
docker ps

echo "✅ Database setup completed - PostgreSQL running on port 5432"