# PalChi Dashboard

A comprehensive SwiftUI dashboard for the PalChi portable chi device management system.

## Features

### Dashboard Layout

The main dashboard is optimized for iPad landscape orientation and consists of four main panels:

#### 1. Quick Actions Panel (Top)
- **Record Session**: Manually trigger a new session recording
- **Force Sync**: Manually synchronize local data with the cloud
- **Refresh Data**: Reload recent sessions and storage statistics

#### 2. Active Communications Panel (Top Left)
- Real-time display of connected PalChi devices
- Device connection status (Connected, Connecting, Disconnected)
- Signal strength indicators
- Last seen timestamps
- Device type identification (PalChi Device, Sensor, Gateway)
- Refresh button to scan for new devices

#### 3. Map Panel (Top Right)
- Interactive map showing session locations
- Session markers with location data
- Highlighted selected session with detailed annotation
- Automatic map centering when session is selected
- Google Maps-style interface using MapKit

#### 4. Session Summary Panel (Bottom)
- **Recent Sessions List**: 
  - Session ID and action type
  - Timestamp (relative time display)
  - Sync status indicators
  - Session duration
  - Clickable rows for selection
- **Storage Statistics**:
  - Storage usage percentage with progress bar
  - Total sessions count
  - Unsynced sessions count
  - Total storage size in human-readable format

## Technical Implementation

### Architecture
- **MVVM Pattern**: Uses `@StateObject` and `@ObservableObject` for reactive UI updates
- **Async/Await**: Modern Swift concurrency for data loading and synchronization
- **Modular Components**: Separate files for dashboard components and models

### Key Components

#### PALCHIApp (ObservableObject)
- Manages session recording and synchronization
- Provides published properties for UI binding
- Handles storage statistics and recent sessions

#### Dashboard Panels
- `ActiveCommunicationsPanel`: Device connection management
- `MapPanel`: Location visualization with MapKit
- `SessionSummaryPanel`: Session data and storage stats
- `QuickActionsPanel`: Common user actions

#### Supporting Models
- `DeviceConnection`: Device status and metadata
- `SessionLocation`: Map annotation data
- `StorageStats`: Storage usage information

### Data Flow
1. Dashboard loads initial data on appear
2. User interactions trigger async operations
3. Published properties update UI reactively
4. Pull-to-refresh updates all panels
5. Session selection updates map highlighting

## Usage

The dashboard automatically loads when the app starts and provides:
- Real-time device monitoring
- Session location tracking
- Storage management
- Quick access to common operations

## Mock Data

For development and testing, the dashboard includes:
- Simulated device connections
- Generated session data with locations
- Realistic storage statistics
- Random data for demonstration

## Future Enhancements

- Real-time device discovery via Bluetooth/WiFi
- Advanced filtering and search for sessions
- Export functionality for session data
- Detailed session analytics and charts
- Push notifications for device status changes