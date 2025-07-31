# Lambda Functions

## Structure

Each Lambda function has its own directory with the following structure:

```
lambda/
├── cart-validator/
│   ├── src/
│   │   ├── index.js          # Main handler
│   │   ├── validator.js      # Business logic
│   │   └── utils.js          # Utility functions
│   ├── package.json          # Dependencies
│   ├── .eslintrc.json        # Linting configuration
│   └── README.md             # Function documentation
├── stock-checker/
│   ├── src/
│   │   ├── index.py          # Main handler (Python)
│   │   ├── dynamo_client.py  # DynamoDB operations
│   │   └── models.py         # Data models
│   ├── requirements.txt      # Python dependencies
│   └── README.md             # Function documentation
├── payment-processor/
│   ├── src/
│   │   ├── index.ts          # Main handler (TypeScript)
│   │   ├── payment.service.ts # Payment logic
│   │   └── types.ts          # Type definitions
│   ├── package.json
│   ├── tsconfig.json
│   └── README.md
└── order-generator/
    ├── src/
    │   ├── index.js
    │   ├── order.service.js
    │   └── notifications.js
    ├── package.json
    └── README.md
```

## Terraform Integration

Each function directory is referenced in the corresponding Terraform module:

```hcl
# modules/lambda/cart-validator/main.tf
data "archive_file" "cart_validator_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../../lambda/cart-validator/src"
  output_path = "${path.module}/cart-validator.zip"
}

resource "aws_lambda_function" "cart_validator" {
  filename         = data.archive_file.cart_validator_zip.output_path
  function_name    = "cart-validator-${var.environment}"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "nodejs18.x"
  source_code_hash = data.archive_file.cart_validator_zip.output_base64sha256
}
```

## Development Workflow

1. **Local Development**: Code in `lambda/function-name/src/`
2. **Testing**: Unit tests in `lambda/function-name/tests/`
3. **Packaging**: Terraform handles ZIP creation automatically
4. **Deployment**: `terraform apply` updates function code