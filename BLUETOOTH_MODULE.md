# Bluetooth Module Documentation

## Overview

The Bluetooth module in this application establishes a connection between the mobile app and height-adjustable desks. It uses Bluetooth Low Energy (BLE) to discover, connect to, and control compatible desk devices, enabling users to adjust desk heights, save memory positions, and monitor desk usage.

## Technical Architecture

The module follows a layered architecture approach:

1. **Permission Layer** - Handles Bluetooth and location permissions required for scanning and connecting
2. **Controller Layer** - Manages Bluetooth state, device discovery, and connection
3. **Service Layer** - Handles specific desk device configurations and command protocols

## Core Components

### BluetoothPermissionController

This utility class manages the permission requirements for Bluetooth functionality:

- Checks and requests necessary permissions (Bluetooth scan, connect, and location)
- Provides methods to open system settings if permissions are permanently denied
- Monitors permission state changes and notifies the application

### BluetoothController

The main controller responsible for managing the Bluetooth adapter state:

- Initializes the Bluetooth adapter and monitors its state (on/off)
- Provides methods to start/stop scanning for nearby devices
- Filters devices based on supported service UUIDs
- Handles connection state management and reconnection logic

### DeskController

Handles specific desk-related operations:

- Establishes connection with desk devices
- Discovers services and characteristics
- Sends control commands (move up/down, stop, memory positions)
- Monitors height changes through BLE notifications
- Converts between different height measurement units (mm/inches)
- Persists and retrieves desk configurations and settings

### DeskServiceConfig

Contains configuration profiles for different desk device models:

- Defines service and characteristic UUIDs for different desk types
- Provides command templates for various desk operations
- Handles protocol differences between desk manufacturers

## Connection Process

1. **Permission Verification**
   - App checks and requests necessary Bluetooth and location permissions
   - If permissions are denied, user is guided to enable them

2. **Device Discovery**
   - App scans for nearby BLE devices advertising specific service UUIDs
   - Filtered devices are displayed to the user in the scanning interface
   - Device signal strength (RSSI) is shown to help identify nearby devices

3. **Device Connection**
   - User selects a device from the discovered list
   - App attempts to connect to the selected device
   - Connection state is monitored and displayed to the user
   - Connected device information is saved for automatic reconnection

4. **Service Discovery**
   - App discovers available services on the connected device
   - Identifies control and notification characteristics
   - Sets up notification handlers for real-time height updates

## Communication Protocol

The app communicates with desk devices using a binary protocol over BLE:

### Command Structure

Commands generally follow this structure:
```
[Header bytes, Command ID, Data length, Data bytes, Checksum]
```

### Key Commands

1. **Movement Controls**
   - Move Up: `[0xF1, 0xF1, 0x01, 0x00, 0x01, 0x7E]`
   - Move Down: `[0xF1, 0xF1, 0x02, 0x00, 0x02, 0x7E]`
   - Stop: `[0xF1, 0xF1, 0x0A, 0x00, 0x0A, 0x7E]`

2. **Memory Position Operations**
   - Set Memory Position 1: `[0xF1, 0xF1, 0x03, 0x00, 0x03, 0x7E]`
   - Set Memory Position 2: `[0xF1, 0xF1, 0x04, 0x00, 0x04, 0x7E]`
   - Set Memory Position 3: `[0xF1, 0xF1, 0x25, 0x00, 0x25, 0x7E]`
   - Move to Memory Position 1: `[0xF1, 0xF1, 0x05, 0x00, 0x05, 0x7E]`
   - Move to Memory Position 2: `[0xF1, 0xF1, 0x06, 0x00, 0x06, 0x7E]`
   - Move to Memory Position 3: `[0xF1, 0xF1, 0x26, 0x00, 0x26, 0x7E]`

3. **Device Configuration**
   - Request Height Range: `[0xF1, 0xF1, 0x0C, 0x00, 0x0C, 0x7E]`
   - Change Device Name: Custom command with name encoded as bytes
   - Reset Device: `[0x01, 0xFC, 0x19, 0x01, 0x00]`

### Height Notification Format

The desk device sends height updates as byte arrays that are parsed by the application:
- Height is typically encoded as millimeters in hexadecimal format
- The app converts these values to the user's preferred unit (inches or centimeters)
- Additional status information may be included in the notification data

## Unit Conversion

The module implements conversion between different measurement units:
- Millimeters to inches: `height_mm / 25.4`
- Inches to millimeters: `height_inches * 25.4`
- Raw hex data to height values using bitwise operations

## Device Types and Compatibility

The module supports multiple desk device types through service detection:

1. **Type A Devices** (Service UUID: ff12)
   - Control Characteristic: ff01
   - Height Report Characteristic: ff02
   - Info Characteristic: ff06

2. **Type B Devices** (Service UUID: fe60)
   - Control Characteristic: fe61
   - Height Report Characteristic: fe62
   - Info Characteristic: fe63

## Data Persistence

The module stores several types of information persistently:

1. **Device Information**
   - Last connected device
   - Device name and identifier
   - Desk height range (min/max)

2. **User Preferences**
   - Memory positions
   - Preferred measurement unit
   - Height adjustment speed

3. **Usage Statistics**
   - Standing/sitting time
   - Position change frequency
   - Height preferences over time

## Error Handling

The module implements comprehensive error handling for common Bluetooth issues:

- Connection timeouts
- Device disconnections
- Missing services or characteristics
- Permission denials
- Invalid commands or responses

Error recovery mechanisms attempt to reconnect automatically or guide the user through troubleshooting steps.

## Integration with Backend

The Bluetooth module integrates with the application's backend services:

- Registers desk devices with user accounts
- Synchronizes memory positions and settings across devices
- Reports usage statistics for health analytics
- Receives firmware updates or new device configurations

## Performance Considerations

The module is optimized for battery efficiency and responsiveness:

- Uses scan filters to minimize unnecessary device discovery
- Implements connection timeouts to prevent battery drain
- Batches commands when possible to reduce radio usage
- Disconnects when app is backgrounded for extended periods

## Security

The module implements security measures for Bluetooth communication:

- Requires explicit user permission before connecting to devices
- Uses device bonding when available for secure connections
- Does not store or transmit sensitive information over BLE
- Validates device identifiers before attempting connections