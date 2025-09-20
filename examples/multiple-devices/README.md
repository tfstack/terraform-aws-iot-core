# Multiple IoT Devices Example

This example demonstrates how to create multiple IoT things with a shared policy using the terraform-aws-iot-core module.

## What it creates

- 3 IoT Things (device-001, device-002, device-003)
- 3 IoT Certificates (one per device)
- 1 Shared IoT Policy
- Policy attachment to all certificates
- Certificate attachment to respective things

## Usage

### 1. Initialize and Deploy

```bash
# Navigate to the multiple devices example
cd examples/multiple-devices

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
terraform output device_names
terraform output device_count
terraform output endpoint

# View sensitive outputs (certificates)
terraform output certificate_pems
terraform output private_keys
```

## Configuration

This example uses a single `main.tf` file with:

- **Local values** - `device_names` and `name_prefix` are hardcoded
- **No variables** - Everything is self-contained
- **Essential outputs only** - Just what's needed for ESP32

## Outputs

| Name            | Description                   | Sensitive |
| --------------- | ----------------------------- | :-------: |
| device_names    | Names of the created IoT things |    no     |
| certificate_pems | IoT certificate PEMs          |    yes    |
| private_keys    | IoT certificate private keys  |    yes    |
| public_keys     | IoT certificate public keys   |    yes    |
| endpoint        | IoT endpoint                  |    no     |
| device_count    | Number of devices created     |    no     |

## Policy

The example creates a shared IoT policy that allows all devices to:

- **Connect** to IoT Core (with thing attachment condition)
- **Publish** to topics under `device/*` and device shadows
- **Subscribe** to topics under `device/*` and device shadows
- **Receive** messages from subscribed topics

### Policy Features

- **Security**: Uses `iot:Connection.Thing.IsAttached` condition for connect
- **Shadow Access**: Includes device shadow read/write permissions
- **Shared Access**: All devices can communicate with each other
- **Least Privilege**: Only necessary permissions granted

## ESP32 Integration

### 1. Use Generated Configuration

The `esp32_config.json` file contains all the values you need for each device:

```json
{
  "device_names": {
    "value": ["device-001", "device-002", "device-003"]
  },
  "endpoint": {
    "value": "iot.ap-southeast-2.amazonaws.com"
  },
  "certificate_pems": {
    "value": ["-----BEGIN CERTIFICATE-----\n...", "-----BEGIN CERTIFICATE-----\n...", "-----BEGIN CERTIFICATE-----\n..."],
    "sensitive": true
  },
  "private_keys": {
    "value": ["-----BEGIN RSA PRIVATE KEY-----\n...", "-----BEGIN RSA PRIVATE KEY-----\n...", "-----BEGIN RSA PRIVATE KEY-----\n..."],
    "sensitive": true
  }
}
```

### 2. Available Values

- `device_names` - Array of device names
- `endpoint` - MQTT broker endpoint (shared)
- `certificate_pems` - Array of device certificates
- `private_keys` - Array of device private keys
- `public_keys` - Array of device public keys
- `device_count` - Number of devices created

## Testing

### 1. Test Device Communication

Use AWS IoT Core Console → Test → MQTT test client:

**Subscribe to**: `device/device-001/data`
**Publish to**: `device/device-002/commands`

### 2. Test Device Shadows

**Subscribe to**: `$aws/things/device-001/shadow/update/accepted`
**Publish to**: `$aws/things/device-001/shadow/update`

## Cleanup

```bash
# Destroy resources
terraform destroy
```

## File Structure

```plaintext
examples/multiple-devices/
├── main.tf          # Complete configuration (locals, resources, outputs)
└── README.md        # This documentation
```

**Note**: This example uses a single `main.tf` file for simplicity. No separate `variables.tf` or `outputs.tf` files needed.
