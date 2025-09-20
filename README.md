# terraform-aws-iot-core

Terraform module for creating and managing AWS IoT Core resources

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.iot_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iot_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iot_certificate) | resource |
| [aws_iot_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iot_policy) | resource |
| [aws_iot_policy_attachment.existing_policy_attachments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iot_policy_attachment) | resource |
| [aws_iot_policy_attachment.inline_policy_attachments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iot_policy_attachment) | resource |
| [aws_iot_thing.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iot_thing) | resource |
| [aws_iot_thing_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iot_thing_group) | resource |
| [aws_iot_thing_group_membership.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iot_thing_group_membership) | resource |
| [aws_iot_thing_principal_attachment.attachments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iot_thing_principal_attachment) | resource |
| [aws_iot_thing_type.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iot_thing_type) | resource |
| [aws_iot_topic_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iot_topic_rule) | resource |
| [aws_s3_bucket.iot_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.iot_data_force_destroy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.iot_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.iot_data_force_destroy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_versioning.iot_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.iot_data_force_destroy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iot_endpoint.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iot_endpoint) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_certificates"></a> [create\_certificates](#input\_create\_certificates) | Whether to create IoT certificates | `bool` | `true` | no |
| <a name="input_create_dynamodb_table"></a> [create\_dynamodb\_table](#input\_create\_dynamodb\_table) | Whether to create a DynamoDB table for IoT data | `bool` | `false` | no |
| <a name="input_create_s3_bucket"></a> [create\_s3\_bucket](#input\_create\_s3\_bucket) | Whether to create an S3 bucket for IoT data | `bool` | `false` | no |
| <a name="input_dynamodb_attributes"></a> [dynamodb\_attributes](#input\_dynamodb\_attributes) | DynamoDB table attributes | <pre>list(object({<br/>    name = string<br/>    type = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "name": "deviceId",<br/>    "type": "S"<br/>  },<br/>  {<br/>    "name": "timestamp",<br/>    "type": "N"<br/>  }<br/>]</pre> | no |
| <a name="input_dynamodb_hash_key"></a> [dynamodb\_hash\_key](#input\_dynamodb\_hash\_key) | DynamoDB table hash key | `string` | `"deviceId"` | no |
| <a name="input_dynamodb_range_key"></a> [dynamodb\_range\_key](#input\_dynamodb\_range\_key) | DynamoDB table range key | `string` | `"timestamp"` | no |
| <a name="input_dynamodb_table_name"></a> [dynamodb\_table\_name](#input\_dynamodb\_table\_name) | Name of the DynamoDB table for IoT data | `string` | `null` | no |
| <a name="input_dynamodb_ttl_attribute"></a> [dynamodb\_ttl\_attribute](#input\_dynamodb\_ttl\_attribute) | DynamoDB TTL attribute name | `string` | `"ttl"` | no |
| <a name="input_dynamodb_ttl_enabled"></a> [dynamodb\_ttl\_enabled](#input\_dynamodb\_ttl\_enabled) | Whether to enable DynamoDB TTL | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for resource names | `string` | `"iot"` | no |
| <a name="input_policy_arn"></a> [policy\_arn](#input\_policy\_arn) | Existing IoT policy ARN (mutually exclusive with policy\_json) | `string` | `null` | no |
| <a name="input_policy_json"></a> [policy\_json](#input\_policy\_json) | Inline IoT policy JSON (mutually exclusive with policy\_arn) | `string` | `null` | no |
| <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name) | Name for the inline IoT policy (required if policy\_json is provided) | `string` | `null` | no |
| <a name="input_rules"></a> [rules](#input\_rules) | Map of IoT topic rules to create | <pre>map(object({<br/>    description = optional(string)<br/>    enabled     = optional(bool, true)<br/>    sql         = string<br/>    sql_version = optional(string, "2016-03-23")<br/>    s3 = optional(object({<br/>      bucket_name = string<br/>      key         = string<br/>      role_arn    = string<br/>    }))<br/>    lambda = optional(object({<br/>      function_arn = string<br/>    }))<br/>    kinesis = optional(object({<br/>      role_arn      = string<br/>      stream_name   = string<br/>      partition_key = optional(string)<br/>    }))<br/>    dynamodb = optional(object({<br/>      table_name      = string<br/>      hash_key_field  = string<br/>      hash_key_value  = string<br/>      range_key_field = optional(string)<br/>      range_key_value = optional(string)<br/>      role_arn        = string<br/>    }))<br/>    cloudwatch_logs = optional(object({<br/>      log_group_name = string<br/>      role_arn       = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Name of the S3 bucket for IoT data | `string` | `null` | no |
| <a name="input_s3_data_retention_days"></a> [s3\_data\_retention\_days](#input\_s3\_data\_retention\_days) | Number of days to retain data in S3 | `number` | `30` | no |
| <a name="input_s3_force_destroy"></a> [s3\_force\_destroy](#input\_s3\_force\_destroy) | Whether to force destroy the S3 bucket (allows non-empty bucket deletion) | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resources | `map(string)` | `{}` | no |
| <a name="input_thing_attributes"></a> [thing\_attributes](#input\_thing\_attributes) | Map of attributes for IoT things | `map(string)` | `{}` | no |
| <a name="input_thing_group_memberships"></a> [thing\_group\_memberships](#input\_thing\_group\_memberships) | Map of thing group memberships | <pre>map(object({<br/>    thing_group_name = string<br/>    thing_name       = string<br/>  }))</pre> | `{}` | no |
| <a name="input_thing_groups"></a> [thing\_groups](#input\_thing\_groups) | Map of IoT thing groups to create | <pre>map(object({<br/>    description       = string<br/>    parent_group_name = optional(string)<br/>    tags              = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_thing_names"></a> [thing\_names](#input\_thing\_names) | List of IoT thing names to create | `list(string)` | `[]` | no |
| <a name="input_thing_type_name"></a> [thing\_type\_name](#input\_thing\_type\_name) | IoT thing type name (optional) | `string` | `null` | no |
| <a name="input_thing_types"></a> [thing\_types](#input\_thing\_types) | Map of IoT thing types to create | <pre>map(object({<br/>    description           = string<br/>    searchable_attributes = list(string)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | AWS account ID |
| <a name="output_certificate_arns"></a> [certificate\_arns](#output\_certificate\_arns) | List of IoT certificate ARNs |
| <a name="output_certificate_pems"></a> [certificate\_pems](#output\_certificate\_pems) | List of IoT certificate PEMs (sensitive) |
| <a name="output_certificate_private_keys"></a> [certificate\_private\_keys](#output\_certificate\_private\_keys) | List of IoT certificate private keys (sensitive) |
| <a name="output_certificate_public_keys"></a> [certificate\_public\_keys](#output\_certificate\_public\_keys) | List of IoT certificate public keys (sensitive) |
| <a name="output_dynamodb_table_arn"></a> [dynamodb\_table\_arn](#output\_dynamodb\_table\_arn) | DynamoDB table ARN for IoT data |
| <a name="output_dynamodb_table_name"></a> [dynamodb\_table\_name](#output\_dynamodb\_table\_name) | DynamoDB table name for IoT data |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | IoT endpoint |
| <a name="output_policy_arn"></a> [policy\_arn](#output\_policy\_arn) | IoT policy ARN (inline policy or provided ARN) |
| <a name="output_policy_name"></a> [policy\_name](#output\_policy\_name) | IoT policy name |
| <a name="output_region"></a> [region](#output\_region) | AWS region |
| <a name="output_rule_arns"></a> [rule\_arns](#output\_rule\_arns) | Map of IoT topic rule ARNs |
| <a name="output_rule_names"></a> [rule\_names](#output\_rule\_names) | Map of IoT topic rule names |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | S3 bucket ARN for IoT data |
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | S3 bucket name for IoT data |
| <a name="output_thing_arns"></a> [thing\_arns](#output\_thing\_arns) | List of IoT thing ARNs |
| <a name="output_thing_group_arns"></a> [thing\_group\_arns](#output\_thing\_group\_arns) | Map of IoT thing group ARNs |
| <a name="output_thing_group_names"></a> [thing\_group\_names](#output\_thing\_group\_names) | Map of IoT thing group names |
| <a name="output_thing_names"></a> [thing\_names](#output\_thing\_names) | List of IoT thing names |
| <a name="output_thing_type_arns"></a> [thing\_type\_arns](#output\_thing\_type\_arns) | Map of IoT thing type ARNs |
| <a name="output_thing_type_names"></a> [thing\_type\_names](#output\_thing\_type\_names) | Map of IoT thing type names |
<!-- END_TF_DOCS -->
