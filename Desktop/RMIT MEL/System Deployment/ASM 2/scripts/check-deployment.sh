#!/bin/bash

# Deployment Check Script - Optional utility
# This script checks if your deployment is working

echo "=========================================="
echo "   DEPLOYMENT HEALTH CHECK"
echo "   Student: ch3mss"
echo "   Date: $(date)"
echo "=========================================="

# Check if Terraform is working
check_terraform() {
    echo "🔍 Checking Terraform status..."
    cd terraform
    
    if terraform show > /dev/null 2>&1; then
        echo "✅ Terraform state is healthy"
    else
        echo "⚠️  Terraform state not found or corrupted"
    fi
    
    cd ..
}

# Check if AWS credentials are working
check_aws() {
    echo "🔍 Checking AWS credentials..."
    
    if aws sts get-caller-identity > /dev/null 2>&1; then
        echo "✅ AWS credentials are working"
        aws sts get-caller-identity --query 'Account' --output text
    else
        echo "❌ AWS credentials not configured"
    fi
}

# Get application URLs
get_urls() {
    echo "🔍 Getting application URLs..."
    cd terraform
    
    FRONTEND_URL=$(terraform output -raw frontend_url 2>/dev/null || echo "Not deployed yet")
    echo "🌐 Frontend URL: $FRONTEND_URL"
    
    if [ "$FRONTEND_URL" != "Not deployed yet" ]; then
        echo "🧪 Testing frontend accessibility..."
        if curl -f -s "$FRONTEND_URL" > /dev/null 2>&1; then
            echo "✅ Frontend is responding!"
        else
            echo "⚠️  Frontend not responding (may still be starting up)"
        fi
    fi
    
    cd ..
}

# Main function
main() {
    check_terraform
    echo ""
    check_aws
    echo ""
    get_urls
    echo ""
    echo "=========================================="
    echo "Health check completed!"
    echo "=========================================="
}

main "$@"