resource "aws_dynamodb_table" "products-dynamodb-table" {
  name           = var.table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 2
  write_capacity = 2
  hash_key       = "productId"

  attribute {
    name = "productId"
    type = "S"
  }

  tags = {
    Environment = var.environment
  }
}

locals {
  products = jsondecode(file("${path.module}/resources/products.json"))
}

resource "aws_dynamodb_table_item" "products" {
  for_each = { for p in local.products : p.productId.S => p }
  table_name = aws_dynamodb_table.products-dynamodb-table.name
  hash_key = "productId"
  item = jsonencode(each.value)
}
