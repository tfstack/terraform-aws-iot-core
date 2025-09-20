# terraform-aws-iot-core
# Outputs for AWS IoT Core Terraform Module

output "thing_names" {
  description = "List of IoT thing names"
  value       = aws_iot_thing.this[*].name
}

output "thing_arns" {
  description = "List of IoT thing ARNs"
  value       = aws_iot_thing.this[*].arn
}

output "certificate_arns" {
  description = "List of IoT certificate ARNs"
  value       = var.create_certificates ? aws_iot_certificate.this[*].arn : []
}

output "certificate_pems" {
  description = "List of IoT certificate PEMs (sensitive)"
  value       = var.create_certificates ? aws_iot_certificate.this[*].certificate_pem : []
  sensitive   = true
}

output "certificate_private_keys" {
  description = "List of IoT certificate private keys (sensitive)"
  value       = var.create_certificates ? aws_iot_certificate.this[*].private_key : []
  sensitive   = true
}

output "certificate_public_keys" {
  description = "List of IoT certificate public keys (sensitive)"
  value       = var.create_certificates ? aws_iot_certificate.this[*].public_key : []
  sensitive   = true
}

output "policy_arn" {
  description = "IoT policy ARN (inline policy or provided ARN)"
  value       = var.policy_json != null ? aws_iot_policy.this[0].arn : var.policy_arn
}

output "policy_name" {
  description = "IoT policy name"
  value       = var.policy_json != null ? aws_iot_policy.this[0].name : null
}

output "rule_arns" {
  description = "Map of IoT topic rule ARNs"
  value       = { for k, v in aws_iot_topic_rule.this : k => v.arn }
}

output "rule_names" {
  description = "Map of IoT topic rule names"
  value       = { for k, v in aws_iot_topic_rule.this : k => v.name }
}

output "endpoint" {
  description = "IoT endpoint"
  value       = "iot.${data.aws_region.current.id}.amazonaws.com"
}

output "account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "region" {
  description = "AWS region"
  value       = data.aws_region.current.id
}

# Thing Types
output "thing_type_names" {
  description = "Map of IoT thing type names"
  value       = { for k, v in aws_iot_thing_type.this : k => v.name }
}

output "thing_type_arns" {
  description = "Map of IoT thing type ARNs"
  value       = { for k, v in aws_iot_thing_type.this : k => v.arn }
}

# Thing Groups
output "thing_group_names" {
  description = "Map of IoT thing group names"
  value       = { for k, v in aws_iot_thing_group.this : k => v.name }
}

output "thing_group_arns" {
  description = "Map of IoT thing group ARNs"
  value       = { for k, v in aws_iot_thing_group.this : k => v.arn }
}

# S3 Bucket
output "s3_bucket_name" {
  description = "S3 bucket name for IoT data"
  value = var.create_s3_bucket ? (
    var.s3_force_destroy ? aws_s3_bucket.iot_data_force_destroy[0].bucket : aws_s3_bucket.iot_data[0].bucket
  ) : null
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN for IoT data"
  value = var.create_s3_bucket ? (
    var.s3_force_destroy ? aws_s3_bucket.iot_data_force_destroy[0].arn : aws_s3_bucket.iot_data[0].arn
  ) : null
}

# DynamoDB Table
output "dynamodb_table_name" {
  description = "DynamoDB table name for IoT data"
  value       = var.create_dynamodb_table ? aws_dynamodb_table.iot_data[0].name : null
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN for IoT data"
  value       = var.create_dynamodb_table ? aws_dynamodb_table.iot_data[0].arn : null
}
