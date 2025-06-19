import Foundation
import CoreData

class DeviceManager {
    private let coreDataStack = CoreDataStack.shared
    
    // MARK: - Device Management
    
    func saveDevice(_ deviceData: DeviceData) -> Bool {
        let context = coreDataStack.context
        
        let device = Device(context: context)
        device.id = deviceData.id
        device.deviceId = deviceData.deviceId
        device.name = deviceData.name
        device.type = deviceData.type.rawValue
        device.firmwareVersion = deviceData.firmwareVersion
        device.batteryLevel = Int16(deviceData.batteryLevel ?? 0)
        device.lastSeen = deviceData.lastSeen
        device.isConnected = deviceData.isConnected
        device.signalStrength = Int16(deviceData.signalStrength ?? 0)
        
        coreDataStack.save()
        return true
    }
    
    func getAllDevices() -> [DeviceData] {
        let context = coreDataStack.context
        let request: NSFetchRequest<Device> = Device.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let devices = try context.fetch(request)
            return devices.compactMap { $0.toDeviceData() }
        } catch {
            print("Error fetching devices: \(error)")
            return []
        }
    }
    
    func getConnectedDevices() -> [DeviceData] {
        let context = coreDataStack.context
        let request: NSFetchRequest<Device> = Device.fetchRequest()
        request.predicate = NSPredicate(format: "isConnected == YES")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let devices = try context.fetch(request)
            return devices.compactMap { $0.toDeviceData() }
        } catch {
            print("Error fetching connected devices: \(error)")
            return []
        }
    }
    
    func updateDeviceConnectionStatus(_ deviceId: String, isConnected: Bool) -> Bool {
        let context = coreDataStack.context
        let request: NSFetchRequest<Device> = Device.fetchRequest()
        request.predicate = NSPredicate(format: "deviceId == %@", deviceId)
        request.fetchLimit = 1
        
        do {
            let devices = try context.fetch(request)
            if let device = devices.first {
                device.isConnected = isConnected
                device.lastSeen = Date()
                coreDataStack.save()
                return true
            }
        } catch {
            print("Error updating device connection status: \(error)")
        }
        return false
    }
    
    func deleteDevice(_ deviceId: String) -> Bool {
        let context = coreDataStack.context
        let request: NSFetchRequest<Device> = Device.fetchRequest()
        request.predicate = NSPredicate(format: "deviceId == %@", deviceId)
        
        do {
            let devices = try context.fetch(request)
            for device in devices {
                context.delete(device)
            }
            coreDataStack.save()
            return true
        } catch {
            print("Error deleting device: \(error)")
            return false
        }
    }
}

// MARK: - Device Core Data Extension

extension Device {
    func toDeviceData() -> DeviceData? {
        guard let id = self.id,
              let deviceId = self.deviceId,
              let name = self.name,
              let typeString = self.type,
              let deviceType = DeviceData.DeviceType(rawValue: typeString) else {
            return nil
        }
        
        return DeviceData(
            id: id,
            deviceId: deviceId,
            name: name,
            type: deviceType,
            firmwareVersion: self.firmwareVersion,
            batteryLevel: self.batteryLevel > 0 ? Int(self.batteryLevel) : nil,
            lastSeen: self.lastSeen,
            isConnected: self.isConnected,
            signalStrength: self.signalStrength > 0 ? Int(self.signalStrength) : nil
        )
    }
}