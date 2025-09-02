# terraform-aws-iot-core
# Variables for AWS IoT Core Terraform Module

variable "thing_names" {
  description = "List of IoT thing names to create"
  type        = list(string)
  default     = []
}

variable "thing_type_name" {
  description = "IoT thing type name (optional)"
  type        = string
  default     = null
}

variable "thing_types" {
  description = "Map of IoT thing types to create"
  type = map(object({
    description           = string
    searchable_attributes = list(string)
  }))
  default = {}
}

variable "thing_groups" {
  description = "Map of IoT thing groups to create"
  type = map(object({
    description       = string
    parent_group_name = optional(string)
    tags              = optional(map(string), {})
  }))
  default = {}
}

variable "thing_group_memberships" {
  description = "Map of thing group memberships"
  type = map(object({
    thing_group_name = string
    thing_name       = string
  }))
  default = {}
}

variable "thing_attributes" {
  description = "Map of attributes for IoT things"
  type        = map(string)
  default     = {}
}

variable "create_certificates" {
  description = "Whether to create IoT certificates"
  type        = bool
  default     = true
}

variable "policy_json" {
  description = "Inline IoT policy JSON (mutually exclusive with policy_arn)"
  type        = string
  default     = null
}

variable "policy_arn" {
  description = "Existing IoT policy ARN (mutually exclusive with policy_json)"
  type        = string
  default     = null
}

variable "policy_name" {
  description = "Name for the inline IoT policy (required if policy_json is provided)"
  type        = string
  default     = null
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "iot"
}

variable "rules" {
  description = "Map of IoT topic rules to create"
  type = map(object({
    description = optional(string)
    enabled     = optional(bool, true)
    sql         = string
    sql_version = optional(string, "2016-03-23")
    s3 = optional(object({
      bucket_name = string
      key         = string
      role_arn    = string
    }))
    lambda = optional(object({
      function_arn = string
    }))
    kinesis = optional(object({
      role_arn      = string
      stream_name   = string
      partition_key = optional(string)
    }))
    dynamodb = optional(object({
      table_name      = string
      hash_key_field  = string
      hash_key_value  = string
      range_key_field = optional(string)
      range_key_value = optional(string)
      role_arn        = string
    }))
    cloudwatch_logs = optional(object({
      log_group_name = string
      role_arn       = string
    }))
  }))
  default = {}
}

# S3 Configuration
variable "create_s3_bucket" {
  description = "Whether to create an S3 bucket for IoT data"
  type        = bool
  default     = false
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for IoT data"
  type        = string
  default     = null
}

variable "s3_data_retention_days" {
  description = "Number of days to retain data in S3"
  type        = number
  default     = 30
}

variable "s3_force_destroy" {
  description = "Whether to force destroy the S3 bucket (allows non-empty bucket deletion)"
  type        = bool
  default     = false
}

# DynamoDB Configuration
variable "create_dynamodb_table" {
  description = "Whether to create a DynamoDB table for IoT data"
  type        = bool
  default     = false
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for IoT data"
  type        = string
  default     = null
}

variable "dynamodb_hash_key" {
  description = "DynamoDB table hash key"
  type        = string
  default     = "deviceId"
}

variable "dynamodb_range_key" {
  description = "DynamoDB table range key"
  type        = string
  default     = "timestamp"
}

variable "dynamodb_attributes" {
  description = "DynamoDB table attributes"
  type = list(object({
    name = string
    type = string
  }))
  default = [
    {
      name = "deviceId"
      type = "S"
    },
    {
      name = "timestamp"
      type = "N"
    }
  ]
}

variable "dynamodb_ttl_attribute" {
  description = "DynamoDB TTL attribute name"
  type        = string
  default     = "ttl"
}

variable "dynamodb_ttl_enabled" {
  description = "Whether to enable DynamoDB TTL"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
