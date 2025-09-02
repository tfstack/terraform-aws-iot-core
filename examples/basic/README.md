# Basic IoT Thing Example

This example demonstrates how to create a single IoT thing with certificate and policy using the terraform-aws-iot-core module.

## What it creates

- 1 IoT Thing with attributes
- 1 IoT Certificate (with PEM, private key, and public key)
- 1 IoT Policy (comprehensive inline JSON)
- Policy attachment to certificate
- Certificate attachment to thing

## Usage

### 1. Initialize and Deploy

```bash
# Navigate to the basic example
cd examples/basic

# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply configuration
terraform apply
```

### 2. Generate ESP32 Configuration

```bash
# Simply pipe terraform output to file
terraform output -json > esp32_config.json
```

This creates:

- `esp32_config.json` - JSON format with all AWS IoT values

### 3. View Outputs

```bash
# View all outputs
terraform output

# View specific outputs (non-sensitive)
terraform output thing_name
terraform output endpoint

# View sensitive outputs (certificates)
terraform output certificate_pem
terraform output private_key
```

## Configuration

This example uses a single `main.tf` file with:

- **Local values** - `thing_name` is hardcoded as "basic-device"
- **No variables** - Everything is self-contained
- **Essential outputs only** - Just what's needed for ESP32

## Outputs

| Name            | Description                   | Sensitive |
| --------------- | ----------------------------- | :-------: |
| thing_name      | Name of the created IoT thing |    no     |
| certificate_pem | IoT certificate PEM           |    yes    |
| private_key     | IoT certificate private key   |    yes    |
| endpoint        | IoT endpoint                  |    no     |

## Policy

The example creates a comprehensive IoT policy that allows the device to:

- **Connect** to IoT Core (with thing attachment condition)
- **Publish** to topics under `device/{thing_name}/*` and device shadow
- **Subscribe** to topics under `device/{thing_name}/*` and device shadow
- **Receive** messages from subscribed topics

### Policy Features

- **Security**: Uses `iot:Connection.Thing.IsAttached` condition for connect
- **Shadow Access**: Includes device shadow read/write permissions
- **Topic Isolation**: Scoped to device-specific topics
- **Least Privilege**: Only necessary permissions granted

## Thing Attributes

The IoT thing is created with the following attributes:

- `deviceType`: "basic-device"
- `version`: "1.0.0"
- `environment`: "dev"

## ESP32 Integration

### 1. Use Generated Configuration

The `esp32_config.json` file contains all the values you need:

```json
{
  "thing_name": {
    "value": "basic-device"
  },
  "endpoint": {
    "value": "iot.ap-southeast-2.amazonaws.com"
  },
  "certificate_pem": {
    "value": "-----BEGIN CERTIFICATE-----\n...",
    "sensitive": true
  },
  "private_key": {
    "value": "-----BEGIN RSA PRIVATE KEY-----\n...",
    "sensitive": true
  }
}
```

### 2. Available Values

- `thing_name` - Your device name ("basic-device")
- `endpoint` - MQTT broker endpoint
- `certificate_pem` - Device certificate (PEM format)
- `private_key` - Device private key (PEM format)

## Testing

### 1. Test Device Connection

Use AWS IoT Core Console → Test → MQTT test client:

**Subscribe to**: `device/basic-device/data`
**Publish to**: `device/basic-device/commands`

### 2. Test Device Shadow

**Subscribe to**: `$aws/things/basic-device/shadow/update/accepted`
**Publish to**: `$aws/things/basic-device/shadow/update`

### 3. Verify Certificate

```bash
# List certificates
aws iot list-certificates

# Describe the created certificate
aws iot describe-certificate --certificate-id $(aws iot list-certificates --query 'certificates[0].certificateId' --output text)
```

## Cleanup

```bash
# Destroy resources
terraform destroy
```

## Next Steps

This basic example provides the foundation for IoT device connectivity. For more advanced features, see:

- **[Multiple Devices Example](../multiple-devices/)** - Multiple IoT things with shared policy
- **[Rules to S3 Example](../rules-to-s3/)** - IoT topic rules with data processing
- **[ESP32 Examples](../../docs/esp32-examples/)** - ESP32-specific implementations

## File Structure

```plaintext
examples/basic/
├── main.tf          # Complete configuration (locals, resources, outputs)
└── README.md        # This documentation
```

**Note**: This example uses a single `main.tf` file for simplicity. No separate `variables.tf` or `outputs.tf` files needed.
