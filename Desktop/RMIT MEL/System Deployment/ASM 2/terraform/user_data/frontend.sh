#!/bin/bash

# Frontend Instance Setup - Section B (15 marks)
# Frontend container that communicates with backend

echo "Starting frontend setup at $(date)"

# Update system and install Docker
yum update -y
yum install -y docker

# Start Docker service
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Wait for Docker to be ready
sleep 15

# Pull the frontend image
echo "Pulling frontend image..."
docker pull rmitdominichynes/sdo-2025:frontend

# Create environment file with backend URL (Section B requirement)
cat > /tmp/frontend.env << EOF
PORT=3000
BACKEND_URL=${backend_url}
NODE_ENV=production
EOF

# Run frontend container (Section B - publicly reachable on port 3000)
echo "Starting frontend container..."
docker run -d \
  --name frontend \
  --restart always \
  -p 3000:3000 \
  --env-file /tmp/frontend.env \
  rmitdominichynes/sdo-2025:frontend

# Wait and verify frontend is running
sleep 10
docker ps

# Test frontend is responding
echo "Testing frontend availability..."
sleep 5
curl -f http://localhost:3000/ || echo "Frontend still starting up..."

echo "✅ Frontend setup completed - Publicly accessible and can reach backend"