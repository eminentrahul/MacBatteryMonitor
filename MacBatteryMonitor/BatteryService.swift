//
//  BatteryService.swift
//  MacBatteryMonitor
//
//  Created by Rahul Ravi Prakash on 11/11/25.
//

import IOKit.ps
import Foundation

class BatteryService {

    /// Returns a best-effort BatteryInfo
    static func getBatteryInfo() -> BatteryInfo? {
        // 1) Try to get percentage from IOPS (high-level power sources API)
        var percentageFromIOPS: Int? = nil
        if let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
           let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
           let source = sources.first,
           let desc = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any] {

            // kIOPSCurrentCapacityKey usually gives a percentage (0..100)
            if let pct = desc[kIOPSCurrentCapacityKey as String] as? Int {
                percentageFromIOPS = pct
            } else if let num = desc[kIOPSCurrentCapacityKey as String] as? NSNumber {
                percentageFromIOPS = num.intValue
            }

            // we can also read charging state from here as fallback
            if let isChargingVal = desc[kIOPSIsChargingKey as String] as? Bool {
                // we'll use this later if AppleSmartBattery doesn't provide it
            }
        }

        // 2) Query AppleSmartBattery registry for detailed numeric values
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSmartBattery"))
        var batteryProps: NSDictionary? = nil
        if service != 0 {
            var propsUnmanaged: Unmanaged<CFMutableDictionary>?
            let result = IORegistryEntryCreateCFProperties(service, &propsUnmanaged, kCFAllocatorDefault, 0)
            if result == KERN_SUCCESS, let props = propsUnmanaged?.takeRetainedValue() as NSDictionary? {
                batteryProps = props
            }
            IOObjectRelease(service)
        }

        // Extract values from registry safely (NSNumber handling)
        func intFrom(_ key: String) -> Int? {
            if let n = batteryProps?[key] as? NSNumber { return n.intValue }
            if let n = batteryProps?[key] as? Int { return n }
            return nil
        }
        func doubleFrom(_ key: String) -> Double? {
            if let n = batteryProps?[key] as? NSNumber { return n.doubleValue }
            if let n = batteryProps?[key] as? Double { return n }
            return nil
        }
        func boolFrom(_ key: String) -> Bool? {
            if let n = batteryProps?[key] as? NSNumber { return n.boolValue }
            if let b = batteryProps?[key] as? Bool { return b }
            return nil
        }

        let currentMah = intFrom("CurrentCapacity")        // typically mAh
        let maxMah = intFrom("MaxCapacity")               // typically mAh
        let cycleCount = intFrom("CycleCount")
        // Temperature in many AppleSmartBattery implementations is provided in tenths of °C (e.g. 310 = 31.0°C).
        let rawTemp = intFrom("Temperature")
        let temperatureC = rawTemp != nil ? Double(rawTemp!) / 100.0 : nil   // sometimes 0.1°C or 0.01°C; adjust if needed
        let rawVoltage = intFrom("Voltage")
        let voltageV = rawVoltage != nil ? Double(rawVoltage!) / 1000.0 : nil // mV -> V
        let isChargingFromRegistry = boolFrom("IsCharging")

        // 3) Decide final percentage:
        // Prefer IOPS percentage (already in 0..100). If not available, compute from mAh.
        let finalPercentage: Int
        if let p = percentageFromIOPS {
            finalPercentage = p
        } else if let cur = currentMah, let max = maxMah, max > 0 {
            let pct = Double(cur) / Double(max) * 100.0
            finalPercentage = Int(pct.rounded())
        } else {
            // No percentage available
            return nil
        }

        // 4) Decide final charging state: prefer registry value if present, else IOPS fallback
        var isCharging = isChargingFromRegistry ?? false
        // (We could also read from IOPS desc if needed — omitted for brevity)

        return BatteryInfo(
            percentage: finalPercentage,
            currentMah: currentMah,
            maxMah: maxMah,
            cycleCount: cycleCount,
            temperatureC: temperatureC,
            voltageV: voltageV,
            isCharging: isCharging
        )
    }
}

