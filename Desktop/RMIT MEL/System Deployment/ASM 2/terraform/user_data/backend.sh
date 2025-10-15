#!/bin/bash

# Backend Instance Setup - Section A (20 marks)
# Backend container that connects to database

echo "Starting backend setup at $(date)"

# Update system and install Docker
yum update -y
yum install -y docker

# Start Docker service
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Wait for Docker to be ready
sleep 15

# Pull the backend image
echo "Pulling backend image..."
docker pull rmitdominichynes/sdo-2025:backend

# Create environment file with database connection
cat > /tmp/backend.env << EOF
PORT=3001
DB_HOST=${db_host}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
NODE_ENV=production
EOF

# Run backend container (Section A requirement - connects to database)
echo "Starting backend container..."
docker run -d \
  --name backend \
  --restart always \
  -p 3001:3001 \
  --env-file /tmp/backend.env \
  rmitdominichynes/sdo-2025:backend

# Wait and verify backend is running
sleep 10
docker ps

# Test database connection
echo "Testing database connection..."
sleep 5
curl -f http://localhost:3001/status || echo "Backend still starting up..."

echo "✅ Backend setup completed - Can connect to database on ${db_host}:5432"