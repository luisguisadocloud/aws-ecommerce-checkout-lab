#!/bin/bash

# Deployment script for E-commerce Checkout project
# Usage: ./scripts/deploy.sh [environment] [action] [aws_profile]
# Examples:
#   ./scripts/deploy.sh dev plan
#   ./scripts/deploy.sh prod apply personal-aws
#   ./scripts/deploy.sh staging plan work-profile

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Configurable variables
ENVIRONMENT=${1:-dev}
ACTION=${2:-plan}
AWS_PROFILE=${3:-default}
TERRAFORM_DIR="environments/$ENVIRONMENT"

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    print_error "Environment must be dev, staging, or prod"
    exit 1
fi

# Validate action
if [[ ! "$ACTION" =~ ^(plan|apply|destroy|init)$ ]]; then
    print_error "Action must be plan, apply, destroy, or init"
    exit 1
fi

# Verify directory exists
if [[ ! -d "$TERRAFORM_DIR" ]]; then
    print_error "Directory $TERRAFORM_DIR does not exist"
    exit 1
fi

# Set AWS profile for all commands
export AWS_PROFILE=$AWS_PROFILE

# Verify AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS CLI not configured or no permissions for profile: $AWS_PROFILE"
    echo "Available profiles:"
    aws configure list-profiles
    echo "Run: aws configure --profile $AWS_PROFILE"
    exit 1
fi

print_header "E-commerce Checkout Deployment"
print_message "Environment: $ENVIRONMENT"
print_message "Action: $ACTION"
print_message "AWS Profile: $AWS_PROFILE"
print_message "Directory: $TERRAFORM_DIR"
print_message "AWS Account: $(aws sts get-caller-identity --query Account --output text)"
print_message "AWS Region: $(aws configure get region --profile $AWS_PROFILE)"
echo ""

# Change to Terraform directory
cd "$TERRAFORM_DIR"

# Execute Terraform action
case $ACTION in
    "init")
        print_header "Initializing Terraform"
        terraform init
        ;;
    "plan")
        print_header "Planning Terraform Changes"
        terraform plan -var-file="terraform.tfvars"
        ;;
    "apply")
        print_header "Applying Terraform Changes"
        print_warning "This will create/modify AWS resources"
        read -p "Are you sure you want to continue? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            terraform apply -var-file="terraform.tfvars" -auto-approve
        else
            print_message "Deployment cancelled"
            exit 0
        fi
        ;;
    "destroy")
        print_header "Destroying Infrastructure"
        print_error "This will DELETE ALL AWS resources in this environment!"
        read -p "Are you absolutely sure? Type 'yes' to confirm: " -r
        if [[ $REPLY == "yes" ]]; then
            terraform destroy -var-file="terraform.tfvars" -auto-approve
        else
            print_message "Destruction cancelled"
            exit 0
        fi
        ;;
esac

print_message "Operation completed successfully!" 