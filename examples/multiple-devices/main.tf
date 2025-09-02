# Multiple IoT Devices Example
# Creates multiple IoT things with one shared policy

# Provider configuration
provider "aws" {
  region = "ap-southeast-2"
}

# Local values
locals {
  device_names = ["device-001", "device-002", "device-003"]
  name_prefix  = "multi-device"
}

# Data sources
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

module "iot" {
  source = "../../"

  thing_names = local.device_names

  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iot:Connect"
        ]
        Resource = "arn:aws:iot:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:client/*"
        Condition = {
          Bool = {
            "iot:Connection.Thing.IsAttached" = "true"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "iot:Publish"
        ]
        Resource = [
          "arn:aws:iot:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:topic/device/*",
          "arn:aws:iot:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:topic/$${aws}/things/*/shadow/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iot:Subscribe"
        ]
        Resource = [
          "arn:aws:iot:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:topicfilter/device/*",
          "arn:aws:iot:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:topicfilter/$${aws}/things/*/shadow/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iot:Receive"
        ]
        Resource = [
          "arn:aws:iot:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:topic/device/*",
          "arn:aws:iot:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:topic/$${aws}/things/*/shadow/*"
        ]
      }
    ]
  })

  policy_name = "${local.name_prefix}-shared-policy"

  tags = {
    Environment = "development"
    Project     = "iot-multiple-devices-example"
  }
}

# Essential outputs for ESP32 configuration
output "device_names" {
  description = "Names of the created IoT things"
  value       = module.iot.thing_names
}

output "certificate_pems" {
  description = "IoT certificate PEMs (sensitive)"
  value       = module.iot.certificate_pems
  sensitive   = true
}

output "private_keys" {
  description = "IoT certificate private keys (sensitive)"
  value       = module.iot.certificate_private_keys
  sensitive   = true
}

output "public_keys" {
  description = "IoT certificate public keys (sensitive)"
  value       = module.iot.certificate_public_keys
  sensitive   = true
}

output "endpoint" {
  description = "IoT endpoint"
  value       = module.iot.endpoint
}

output "device_count" {
  description = "Number of devices created"
  value       = length(module.iot.thing_names)
}
