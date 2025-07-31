#!/bin/bash

# Script to configure Terraform remote backend
# This script creates the necessary AWS resources for the backend
# Usage: ./scripts/setup-backend.sh [aws_profile]

set -e

# Configurable variables
AWS_PROFILE=${1:-default}
BUCKET_NAME="ecommerce-checkout-terraform-state-$(date +%s)"
DYNAMODB_TABLE="terraform-state-lock"
REGION="us-east-2"
PROJECT_NAME="ecommerce-checkout"

# Set AWS profile
export AWS_PROFILE=$AWS_PROFILE

echo "🚀 Setting up Terraform remote backend..."
echo "AWS Profile: $AWS_PROFILE"
echo "Bucket: $BUCKET_NAME"
echo "Region: $REGION"
echo ""

# Verify AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ Error: AWS CLI is not configured or you don't have permissions for profile: $AWS_PROFILE"
    echo "Available profiles:"
    aws configure list-profiles
    echo "Run: aws configure --profile $AWS_PROFILE"
    exit 1
fi

echo "✅ AWS CLI configured correctly for profile: $AWS_PROFILE"

# Create S3 bucket for state
echo "📦 Creating S3 bucket..."
aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION"

# Enable versioning on bucket
echo "🔄 Enabling bucket versioning..."
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled

# Enable encryption on bucket
echo "🔒 Configuring encryption..."
aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

# Create DynamoDB table for state locking
echo "🔐 Creating DynamoDB table for state locking..."
aws dynamodb create-table \
    --table-name "$DYNAMODB_TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region "$REGION"

# Wait for table to be active
echo "⏳ Waiting for DynamoDB table to be active..."
aws dynamodb wait table-exists \
    --table-name "$DYNAMODB_TABLE" \
    --region "$REGION"

# Create backend configuration file for each environment
echo "📝 Creating backend configuration files..."

# Create for dev environment
mkdir -p environments/dev
cat > environments/dev/backend.tf << EOF
terraform {
  backend "s3" {
    bucket         = "$BUCKET_NAME"
    key            = "dev/terraform.tfstate"
    region         = "$REGION"
    dynamodb_table = "$DYNAMODB_TABLE"
    encrypt        = true
  }
}
EOF

# Create for staging environment
mkdir -p environments/staging
cat > environments/staging/backend.tf << EOF
terraform {
  backend "s3" {
    bucket         = "$BUCKET_NAME"
    key            = "staging/terraform.tfstate"
    region         = "$REGION"
    dynamodb_table = "$DYNAMODB_TABLE"
    encrypt        = true
  }
}
EOF

# Create for prod environment
mkdir -p environments/prod
cat > environments/prod/backend.tf << EOF
terraform {
  backend "s3" {
    bucket         = "$BUCKET_NAME"
    key            = "prod/terraform.tfstate"
    region         = "$REGION"
    dynamodb_table = "$DYNAMODB_TABLE"
    encrypt        = true
  }
}
EOF

echo ""
echo "✅ Backend configured successfully!"
echo ""
echo "📋 Configuration summary:"
echo "   S3 Bucket: $BUCKET_NAME"
echo "   DynamoDB Table: $DYNAMODB_TABLE"
echo "   Region: $REGION"
echo "   Configuration file: backend.tf"
echo ""
echo "🔧 Next steps:"
echo "   1. Review the generated backend.tf files in each environment"
echo "   2. Navigate to your desired environment: cd environments/dev"
echo "   3. Run: terraform init"
echo "   4. Run: terraform plan"
echo "   5. Run: terraform apply"
echo ""
echo "💡 Alternative: Use deployment script"
echo "   ./scripts/deploy.sh dev plan"
echo "   ./scripts/deploy.sh dev apply"
echo ""
echo "⚠️  IMPORTANT: Save these values for future reference:"
echo "   BUCKET_NAME=$BUCKET_NAME"
echo "   DYNAMODB_TABLE=$DYNAMODB_TABLE" 