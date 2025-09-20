# terraform-aws-iot-core
# AWS IoT Core Terraform Module

# Data source for current AWS region
data "aws_region" "current" {}

# Data source for current AWS account ID
data "aws_caller_identity" "current" {}

# Data source for IoT endpoint
data "aws_iot_endpoint" "current" {
  endpoint_type = "iot:Data-ATS"
}

# IoT Thing Types
resource "aws_iot_thing_type" "this" {
  for_each = var.thing_types

  name = each.key
  properties {
    description           = each.value.description
    searchable_attributes = each.value.searchable_attributes
  }
}

# IoT Thing Groups
resource "aws_iot_thing_group" "this" {
  for_each = var.thing_groups

  name              = each.key
  parent_group_name = each.value.parent_group_name
  properties {
    description = each.value.description
  }

  tags = merge(var.tags, each.value.tags)
}

# IoT Things
resource "aws_iot_thing" "this" {
  count = length(var.thing_names)

  name            = var.thing_names[count.index]
  thing_type_name = var.thing_type_name
  attributes      = var.thing_attributes
}

# IoT Certificates
resource "aws_iot_certificate" "this" {
  count = var.create_certificates ? length(var.thing_names) : 0

  active = true
}

# IoT Policy (inline)
resource "aws_iot_policy" "this" {
  count = var.policy_json != null ? 1 : 0

  name   = var.policy_name != null ? var.policy_name : "${var.name_prefix}-iot-policy"
  policy = var.policy_json
}

# IoT Policy Attachments (for inline policy)
resource "aws_iot_policy_attachment" "inline_policy_attachments" {
  count = var.policy_json != null && var.create_certificates ? length(var.thing_names) : 0

  policy = aws_iot_policy.this[0].name
  target = aws_iot_certificate.this[count.index].arn
}

# IoT Policy Attachments (for existing policy ARN)
resource "aws_iot_policy_attachment" "existing_policy_attachments" {
  count = var.policy_arn != null && var.create_certificates ? length(var.thing_names) : 0

  policy = var.policy_arn
  target = aws_iot_certificate.this[count.index].arn
}

# IoT Thing Group Memberships
resource "aws_iot_thing_group_membership" "this" {
  for_each = var.thing_group_memberships

  thing_group_name = each.value.thing_group_name
  thing_name       = each.value.thing_name
}

# IoT Thing Principal Attachments
resource "aws_iot_thing_principal_attachment" "attachments" {
  count = var.create_certificates ? length(var.thing_names) : 0

  principal = aws_iot_certificate.this[count.index].arn
  thing     = aws_iot_thing.this[count.index].name
}

# Optional S3 Bucket for IoT Data (without force destroy)
resource "aws_s3_bucket" "iot_data" {
  count = var.create_s3_bucket && !var.s3_force_destroy ? 1 : 0

  bucket = var.s3_bucket_name

  tags = merge(var.tags, {
    Name                     = var.s3_bucket_name
    "terraform-aws-iot-core" = "true"
  })
}

# Optional S3 Bucket for IoT Data (with force destroy)
resource "aws_s3_bucket" "iot_data_force_destroy" {
  count = var.create_s3_bucket && var.s3_force_destroy ? 1 : 0

  bucket        = var.s3_bucket_name
  force_destroy = true

  tags = merge(var.tags, {
    Name                     = var.s3_bucket_name
    "terraform-aws-iot-core" = "true"
  })
}

# S3 Bucket Versioning (for regular bucket)
resource "aws_s3_bucket_versioning" "iot_data" {
  count = var.create_s3_bucket && !var.s3_force_destroy ? 1 : 0

  bucket = aws_s3_bucket.iot_data[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Versioning (for force destroy bucket)
resource "aws_s3_bucket_versioning" "iot_data_force_destroy" {
  count = var.create_s3_bucket && var.s3_force_destroy ? 1 : 0

  bucket = aws_s3_bucket.iot_data_force_destroy[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Lifecycle Configuration (for regular bucket)
resource "aws_s3_bucket_lifecycle_configuration" "iot_data" {
  count = var.create_s3_bucket && !var.s3_force_destroy ? 1 : 0

  bucket = aws_s3_bucket.iot_data[0].id

  rule {
    id     = "delete_old_data"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = var.s3_data_retention_days
    }
  }
}

# S3 Bucket Lifecycle Configuration (for force destroy bucket)
resource "aws_s3_bucket_lifecycle_configuration" "iot_data_force_destroy" {
  count = var.create_s3_bucket && var.s3_force_destroy ? 1 : 0

  bucket = aws_s3_bucket.iot_data_force_destroy[0].id

  rule {
    id     = "delete_old_data"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = var.s3_data_retention_days
    }
  }
}

# Optional DynamoDB Table for IoT Data
resource "aws_dynamodb_table" "iot_data" {
  count = var.create_dynamodb_table ? 1 : 0

  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.dynamodb_hash_key
  range_key    = var.dynamodb_range_key

  dynamic "attribute" {
    for_each = var.dynamodb_attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  ttl {
    attribute_name = var.dynamodb_ttl_attribute
    enabled        = var.dynamodb_ttl_enabled
  }

  tags = merge(var.tags, {
    Name                     = var.dynamodb_table_name
    "terraform-aws-iot-core" = "true"
  })
}

# IoT Topic Rules
resource "aws_iot_topic_rule" "this" {
  for_each = var.rules

  name        = each.key
  description = each.value.description
  enabled     = each.value.enabled
  sql         = each.value.sql
  sql_version = each.value.sql_version

  # S3 Action
  dynamic "s3" {
    for_each = each.value.s3 != null ? [each.value.s3] : []
    content {
      bucket_name = s3.value.bucket_name
      key         = s3.value.key
      role_arn    = s3.value.role_arn
    }
  }

  # Lambda Action
  dynamic "lambda" {
    for_each = each.value.lambda != null ? [each.value.lambda] : []
    content {
      function_arn = lambda.value.function_arn
    }
  }

  # Kinesis Action
  dynamic "kinesis" {
    for_each = each.value.kinesis != null ? [each.value.kinesis] : []
    content {
      role_arn      = kinesis.value.role_arn
      stream_name   = kinesis.value.stream_name
      partition_key = kinesis.value.partition_key
    }
  }

  # DynamoDB Action
  dynamic "dynamodb" {
    for_each = each.value.dynamodb != null ? [each.value.dynamodb] : []
    content {
      table_name      = dynamodb.value.table_name
      hash_key_field  = dynamodb.value.hash_key_field
      hash_key_value  = dynamodb.value.hash_key_value
      range_key_field = dynamodb.value.range_key_field
      range_key_value = dynamodb.value.range_key_value
      role_arn        = dynamodb.value.role_arn
    }
  }

  # CloudWatch Logs Action
  dynamic "cloudwatch_logs" {
    for_each = each.value.cloudwatch_logs != null ? [each.value.cloudwatch_logs] : []
    content {
      log_group_name = cloudwatch_logs.value.log_group_name
      role_arn       = cloudwatch_logs.value.role_arn
    }
  }

  tags = merge(
    var.tags,
    {
      Name                     = each.key
      "terraform-aws-iot-core" = "true"
    }
  )
}
