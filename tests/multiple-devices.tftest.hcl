# Multiple IoT Devices Test
# Tests multiple IoT things creation with shared policy

provider "aws" {
  region = "ap-southeast-2"
}

run "multiple_iot_devices" {
  command = plan

  variables {
    thing_names = ["device-001", "device-002", "device-003"]
    policy_json = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "iot:Connect"
          ]
          Resource = "arn:aws:iot:ap-southeast-2:123456789012:client/*"
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
            "arn:aws:iot:ap-southeast-2:123456789012:topic/device/*",
            "arn:aws:iot:ap-southeast-2:123456789012:topic/$${aws}/things/*/shadow/*"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "iot:Subscribe"
          ]
          Resource = [
            "arn:aws:iot:ap-southeast-2:123456789012:topicfilter/device/*",
            "arn:aws:iot:ap-southeast-2:123456789012:topicfilter/$${aws}/things/*/shadow/*"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "iot:Receive"
          ]
          Resource = [
            "arn:aws:iot:ap-southeast-2:123456789012:topic/device/*",
            "arn:aws:iot:ap-southeast-2:123456789012:topic/$${aws}/things/*/shadow/*"
          ]
        }
      ]
    })
    policy_name = "multi-device-shared-policy"
    tags = {
      Environment = "development"
      Project     = "iot-multiple-devices-example"
    }
  }

  assert {
    condition     = length(aws_iot_thing.this) == 3
    error_message = "Expected three IoT things to be created"
  }

  assert {
    condition     = aws_iot_thing.this[0].name == "device-001"
    error_message = "Expected first thing name to be 'device-001'"
  }

  assert {
    condition     = aws_iot_thing.this[1].name == "device-002"
    error_message = "Expected second thing name to be 'device-002'"
  }

  assert {
    condition     = aws_iot_thing.this[2].name == "device-003"
    error_message = "Expected third thing name to be 'device-003'"
  }

  assert {
    condition     = length(aws_iot_certificate.this) == 3
    error_message = "Expected three IoT certificates to be created"
  }

  assert {
    condition     = length(aws_iot_policy.this) == 1
    error_message = "Expected one IoT policy to be created"
  }

  assert {
    condition     = aws_iot_policy.this[0].name == "multi-device-shared-policy"
    error_message = "Expected policy name to be 'multi-device-shared-policy'"
  }
}
