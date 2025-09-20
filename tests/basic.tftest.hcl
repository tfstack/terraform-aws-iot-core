# Basic IoT Thing Test
# Tests single IoT thing creation with certificate and policy

provider "aws" {
  region = "ap-southeast-2"
}

run "basic_iot_thing" {
  command = plan

  variables {
    thing_names = ["basic-device"]
    policy_json = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "iot:Connect"
          ]
          Resource = "arn:aws:iot:ap-southeast-2:123456789012:client/basic-device"
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
            "arn:aws:iot:ap-southeast-2:123456789012:topic/device/basic-device/*",
            "arn:aws:iot:ap-southeast-2:123456789012:topic/$${aws}/things/basic-device/shadow/*"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "iot:Subscribe"
          ]
          Resource = [
            "arn:aws:iot:ap-southeast-2:123456789012:topicfilter/device/basic-device/*",
            "arn:aws:iot:ap-southeast-2:123456789012:topicfilter/$${aws}/things/basic-device/shadow/*"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "iot:Receive"
          ]
          Resource = [
            "arn:aws:iot:ap-southeast-2:123456789012:topic/device/basic-device/*",
            "arn:aws:iot:ap-southeast-2:123456789012:topic/$${aws}/things/basic-device/shadow/*"
          ]
        }
      ]
    })
    policy_name = "basic-device-policy"
    tags = {
      Environment = "dev"
      Project     = "iot-basic-example"
      DeviceType  = "basic-device"
    }
  }

  assert {
    condition     = length(aws_iot_thing.this) == 1
    error_message = "Expected one IoT thing to be created"
  }

  assert {
    condition     = aws_iot_thing.this[0].name == "basic-device"
    error_message = "Expected IoT thing name to be 'basic-device'"
  }

  assert {
    condition     = length(aws_iot_certificate.this) == 1
    error_message = "Expected one IoT certificate to be created"
  }

  assert {
    condition     = length(aws_iot_policy.this) == 1
    error_message = "Expected one IoT policy to be created"
  }

  assert {
    condition     = aws_iot_policy.this[0].name == "basic-device-policy"
    error_message = "Expected policy name to be 'basic-device-policy'"
  }
}
