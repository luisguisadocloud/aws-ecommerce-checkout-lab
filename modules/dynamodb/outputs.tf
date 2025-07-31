output "table_name" {
  value = aws_dynamodb_table.products-dynamodb-table.name
}

output "table_arn" {
  value = aws_dynamodb_table.products-dynamodb-table.arn
}
