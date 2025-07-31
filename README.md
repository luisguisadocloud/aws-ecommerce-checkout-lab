# AWS E-commerce Checkout Lab

## Overview

This is an educational repository demonstrating Infrastructure as Code (IaC) best practices for a simulated e-commerce checkout system. The project serves as a learning platform to explore AWS serverless services, modern infrastructure patterns, and backend development practices.

**Purpose**: Educational and portfolio demonstration
**Scope**: Simulated e-commerce system for learning AWS serverless architecture
**Objective**: Showcase professional IaC, backend development, and cloud architecture skills

> **Note**: This is an evolving project. Some components are currently in development and will be implemented progressively over the coming days and weeks. See the [Implementation Status](#implementation-status) section for current progress.

## Learning Objectives

This educational project demonstrates how to build a scalable serverless e-commerce system using AWS best practices. Key learning areas include:

**Infrastructure as Code (IaC)**
- Terraform module design and organization
- Multi-environment deployment strategies
- Remote state management with S3 and DynamoDB
- Resource tagging and cost management

**AWS Serverless Architecture**
- DynamoDB for NoSQL data storage
- Lambda functions for business logic
- Step Functions for workflow orchestration
- API Gateway for REST APIs
- SNS/EventBridge for event-driven communication

**Simulated Business Logic**
- Shopping cart validation
- Real-time inventory management
- Dynamic pricing and discount calculation
- Payment processing simulation
- Order generation and tracking
- Customer notification system

**DevOps Practices**
- Automated deployment scripts
- Environment separation (dev/staging/prod)
- Infrastructure testing and validation
- Documentation and code organization

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   API Gateway   │───▶│  Step Functions │───▶│   Lambda Func   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │                        │
                              ▼                        ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │   DynamoDB      │    │   SNS/EventBridge│
                       │   (Products)    │    │   (Notifications)│
                       └─────────────────┘    └─────────────────┘
```

### Technology Stack

- **Infrastructure**: Terraform
- **Cloud Provider**: AWS
- **Database**: DynamoDB
- **Compute**: AWS Lambda
- **Orchestration**: AWS Step Functions
- **Notifications**: SNS/EventBridge
- **API**: API Gateway
- **State Management**: S3 + DynamoDB

## Project Structure

```
aws-ecommerce-checkout-lab/
├── README.md                    # Project documentation
├── .gitignore                   # Git ignore rules
├── environments/                # Environment-specific configurations
│   ├── dev/                     # Development environment
│   │   ├── main.tf              # Main Terraform configuration
│   │   ├── variables.tf         # Variable definitions
│   │   ├── terraform.tfvars     # Variable values
│   │   ├── outputs.tf           # Output definitions
│   │   └── backend.tf           # Remote state configuration
│   ├── staging/                 # Staging environment
│   └── prod/                    # Production environment
├── modules/                     # Reusable Terraform modules
│   ├── dynamodb/                # DynamoDB table module
│   ├── lambda/                  # Lambda function modules
│   ├── step-functions/          # Step Functions workflows
│   ├── ssm/                     # Systems Manager parameters
│   ├── sns/                     # SNS notification topics
│   └── common/                  # Common resources (tags, etc.)
├── lambda/                      # Lambda function source code
│   ├── cart-validator/          # Cart validation function
│   ├── stock-checker/           # Stock validation function
│   ├── payment-processor/       # Payment processing function
│   └── order-generator/         # Order generation function
├── scripts/                     # Automation scripts
│   ├── setup-backend.sh         # Backend configuration script
│   └── deploy.sh                # Deployment automation script
├── docs/                        # Additional documentation
│   └── getting-started.md       # Quick start guide
└── tests/                       # Infrastructure tests
    └── terraform/               # Terraform validation tests
```

## Prerequisites

Before deploying this infrastructure, ensure you have:

1. **AWS CLI configured**
   ```bash
   aws configure
   # or for specific profile
   aws configure --profile your-profile-name
   ```

2. **Terraform installed** (version >= 1.2)
   ```bash
   terraform version
   ```

3. **Required AWS permissions**
   - DynamoDB: CreateTable, DescribeTable, PutItem, GetItem
   - S3: CreateBucket, PutBucketVersioning, PutBucketEncryption
   - Lambda: CreateFunction, UpdateFunctionCode
   - IAM: CreateRole, AttachRolePolicy
   - Step Functions: CreateStateMachine, StartExecution

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/aws-ecommerce-checkout-lab.git
cd aws-ecommerce-checkout-lab
```

### 2. Set Up Remote Backend

```bash
# Set up Terraform remote state backend
./scripts/setup-backend.sh

# For specific AWS profile
./scripts/setup-backend.sh your-aws-profile
```

### 3. Deploy Development Environment

```bash
# Navigate to development environment
cd environments/dev

# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Deploy infrastructure
terraform apply
```

### 4. Alternative: Use Deployment Script

```bash
# Plan deployment
./scripts/deploy.sh dev plan

# Deploy to development
./scripts/deploy.sh dev apply

# Deploy with specific AWS profile
./scripts/deploy.sh dev apply your-aws-profile
```

## Configuration

### Remote Backend Configuration

The project uses S3 for state storage and DynamoDB for state locking:

```hcl
terraform {
  backend "s3" {
    bucket         = "ecommerce-checkout-terraform-state-XXXXX"
    key            = "dev/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

### Environment Variables

Each environment has its own variable configuration:

```hcl
# environments/dev/terraform.tfvars
environment = "dev"
aws_region  = "us-east-2"
dynamodb_table_name = "products-dev"
```

### Resource Tagging

All resources are tagged consistently:

```hcl
locals {
  common_tags = {
    Project     = "ecommerce-checkout"
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "luisguisado"
    CostCenter  = "portfolio"
  }
}
```

## Development Workflow

### Making Changes

1. **Create feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make changes to Terraform files**
   ```bash
   # Edit files in environments/dev/ or modules/
   ```

3. **Test changes**
   ```bash
   ./scripts/deploy.sh dev plan
   ```

4. **Apply changes**
   ```bash
   ./scripts/deploy.sh dev apply
   ```

5. **Commit and push**
   ```bash
   git add .
   git commit -m "Add: your feature description"
   git push origin feature/your-feature-name
   ```

### Multiple Environments

Deploy to different environments:

```bash
# Development
./scripts/deploy.sh dev apply

# Staging (when ready)
./scripts/deploy.sh staging apply

# Production (after thorough testing)
./scripts/deploy.sh prod apply
```

## Verification

### Check Deployed Resources

```bash
# View Terraform outputs
cd environments/dev
terraform output

# Verify DynamoDB table
aws dynamodb describe-table --table-name products-dev

# List items in table
aws dynamodb scan --table-name products-dev
```

### Resource Monitoring

All resources include standard tags for cost tracking and management:
- Project: ecommerce-checkout
- Environment: dev/staging/prod
- ManagedBy: terraform
- Owner: luisguisado
- CostCenter: portfolio

## Troubleshooting

### Common Issues

**Backend not configured**
```bash
cd environments/dev
terraform init
```

**AWS permissions insufficient**
```bash
aws sts get-caller-identity
aws iam list-attached-user-policies --user-name YOUR_USERNAME
```

**State lock conflicts**
```bash
# Force unlock if needed (use carefully)
terraform force-unlock LOCK_ID
```

### Clean Up Resources

```bash
# Destroy development environment
./scripts/deploy.sh dev destroy

# Manual cleanup
cd environments/dev
terraform destroy
```

## Implementation Status

This project is under active development. Below is the current status of each component:

### Currently Implemented ✅
- **Infrastructure Foundation**: Terraform modules and environment structure
- **Remote State Management**: S3 backend with DynamoDB locking
- **DynamoDB Module**: Product catalog table with sample data
- **Deployment Automation**: Scripts for backend setup and deployment
- **Multi-environment Support**: Dev, staging, and production configurations
- **Documentation**: Comprehensive README and getting started guide

### In Development 🚧
- **Lambda Functions**: Business logic for cart validation, stock checking, payment processing
- **Step Functions**: Workflow orchestration for checkout process
- **API Gateway**: REST endpoints for e-commerce operations
- **SNS/EventBridge**: Event-driven notifications and messaging

### Planned for Implementation 📋
- **Advanced Security**: IAM roles optimization, encryption at rest/transit
- **Monitoring**: CloudWatch dashboards, alarms, and logging
- **Testing**: Infrastructure tests, function unit tests, integration tests
- **CI/CD Pipeline**: Automated testing and deployment workflows
- **Cost Optimization**: Resource right-sizing and cost monitoring
- **Advanced Features**: Caching, performance optimization, disaster recovery

> **Getting Started**: Even though some components are still in development, you can deploy the current infrastructure (DynamoDB and basic setup) by following the [Quick Start](#quick-start) guide.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS DynamoDB Documentation](https://docs.aws.amazon.com/dynamodb/)
- [AWS Step Functions Documentation](https://docs.aws.amazon.com/step-functions/)
- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/)

## License

This project is licensed under the MIT License - see the LICENSE file for details. 