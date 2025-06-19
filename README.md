# PalChi
Your swift pal to your portable chi device

## Overview
PalChi is an iOS application designed to interface with portable chi devices, providing real-time monitoring, data management, and comprehensive analytics. The app features a dashboard-based interface with multiple specialized panels and an administrative backend for device and data management.

## Dashboard Panels

### Quick Actions Panel
**Function**: Provides immediate access to frequently used actions and controls
- Quick device connection/disconnection
- Instant session recording
- Emergency controls
- Status indicators for critical functions
- One-tap access to common chi device operations

### Active Communications Panel
**Function**: Monitors and manages real-time device connectivity
- **Device Discovery**: Automatically scans for available PalChi devices and sensors
- **Connection Status**: Real-time display of device connection states (Connected, Connecting, Disconnected)
- **Signal Strength**: Shows wireless signal quality for each connected device
- **Device Types**: Supports multiple device categories:
  - PalChi Devices (primary chi measurement devices)
  - Sensors (auxiliary measurement devices)
  - Gateways (network bridge devices)
- **Last Seen**: Tracks when devices were last active
- **Manual Refresh**: Allows users to manually scan for new devices

### Map Panel
**Function**: Provides geographical context for chi sessions and device locations
- **Session Mapping**: Displays locations where chi sessions were recorded
- **Interactive Map**: Users can select sessions to view detailed location data
- **Session Correlation**: Links map locations with session data for spatial analysis
- **Location History**: Tracks and visualizes patterns in session locations
- **Geographic Analytics**: Provides insights into location-based chi patterns

### Session Summary Panel
**Function**: Comprehensive overview of recorded chi sessions and data management
- **Recent Sessions**: Displays chronologically ordered list of recent chi measurements
- **Session Details**: Shows session ID, duration, action type, and timestamp
- **Sync Status**: Indicates which sessions have been synchronized to cloud storage
- **Storage Statistics**: Real-time display of local storage usage and capacity
- **Session Selection**: Allows users to select sessions for detailed analysis
- **Data Export**: Facilitates sharing and backup of session data

## Admin Panel Tabs

### Statistics Tab
**Function**: Provides comprehensive database and usage analytics
- **Database Overview**: 
  - Total record counts
  - Database size and performance metrics
  - Storage optimization statistics
- **Session Statistics**:
  - Usage patterns and trends
  - Peak usage times
  - Session duration analytics
  - User engagement metrics
- **Performance Metrics**:
  - Query response times
  - Sync success rates
  - Error frequency analysis

### Connectivity Tab
**Function**: Manages network and device communication settings
- **Network Configuration**: WiFi and cellular connectivity preferences
- **Bluetooth Settings**: Device pairing and connection parameters
- **Sync Preferences**: Cloud synchronization frequency and conditions
- **Connection Troubleshooting**: Diagnostic tools for connectivity issues
- **Protocol Settings**: Communication protocol configuration for different device types

### Devices Tab
**Function**: Comprehensive device management and configuration
- **Device Registration**: Add and configure new PalChi devices
- **Device Profiles**: Manage individual device settings and calibration
- **Firmware Management**: Check and update device firmware
- **Device Health**: Monitor battery levels, sensor status, and performance
- **Pairing Management**: Handle device pairing and authentication

### Location Tab
**Function**: Manages location services and privacy settings
- **Location Permissions**: Configure app location access levels
- **GPS Accuracy**: Set location precision requirements
- **Location History**: Manage stored location data
- **Privacy Controls**: Configure location data sharing and retention
- **Geofencing**: Set up location-based triggers and alerts

### Lists Tab
**Function**: Manages device inventories and user-defined collections
- **Device Inventory**: Comprehensive list of all registered devices
- **User Lists**: Custom collections of devices and sessions
- **Favorites**: Quick access to frequently used devices
- **Device Groups**: Organize devices by location, type, or purpose
- **Bulk Operations**: Perform actions on multiple devices simultaneously

## Database & Offline Data Management

### Local Storage Architecture
**SQLite Database**: The app uses SQLite for robust local data storage with the following features:
- **Primary Storage**: 50MB maximum capacity for offline session data
- **Automatic Management**: Intelligent storage cleanup when approaching capacity limits
- **Data Integrity**: ACID compliance ensures data consistency during power loss or crashes

### Session Data Structure
**Comprehensive Data Model**:
- **Session Metadata**: Unique identifiers, timestamps, user associations
- **Chi Measurements**: Raw sensor data, processed metrics, calibration information
- **Location Data**: GPS coordinates, location names, environmental context
- **Device Information**: Source device details, sensor configurations, firmware versions
- **Sync Status**: Cloud synchronization state, conflict resolution data

### Offline Capabilities
**Seamless Offline Operation**:
- **Full Functionality**: All core features work without internet connectivity
- **Intelligent Queuing**: Automatic queuing of data for synchronization when connection resumes
- **Conflict Resolution**: Smart handling of data conflicts between local and cloud storage
- **Storage Optimization**: Automatic compression and cleanup of old data
- **Data Integrity**: Checksums and validation ensure data accuracy during offline operation

### Cloud Synchronization
**Robust Data Sync**:
- **Automatic Sync**: Background synchronization when network is available
- **Manual Sync**: User-initiated sync for immediate data backup
- **Incremental Updates**: Only changed data is synchronized to minimize bandwidth usage
- **Conflict Resolution**: Intelligent merging of conflicting data from multiple sources
- **Sync Status Tracking**: Real-time indication of synchronization progress and status

### Data Security & Privacy
**Enterprise-Grade Protection**:
- **Local Encryption**: All local data encrypted using device-specific keys
- **Secure Transmission**: TLS encryption for all cloud communications
- **Privacy Controls**: User-configurable data sharing and retention policies
- **Data Anonymization**: Optional anonymization of sensitive personal data
- **Compliance**: Adherence to healthcare data privacy regulations

## Technical Architecture
- **Platform**: iOS (Swift/SwiftUI)
- **Database**: SQLite with custom ORM layer
- **Networking**: RESTful API with offline-first architecture
- **UI Framework**: SwiftUI with responsive design
- **Device Communication**: Bluetooth LE and WiFi protocols
- **Location Services**: Core Location framework integration