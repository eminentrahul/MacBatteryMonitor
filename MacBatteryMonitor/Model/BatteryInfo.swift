//
//  BatteryInfo.swift
//  MacBatteryMonitor
//
//  Created by Rahul Ravi Prakash on 11/11/25.
//

import Foundation
import IOKit
import IOKit.ps

struct BatteryInfo {
    // Primary percent (0-100)
    var percentage: Int

    // mAh values (if available)
    var currentMah: Int?
    var maxMah: Int?

    var cycleCount: Int?
    var temperatureC: Double?   // °C
    var voltageV: Double?       // V
    var isCharging: Bool

    // Fallback health if mAh available
    var healthPercentage: Double? {
        guard let current = currentMah, let max = maxMah, max > 0 else { return nil }
        return Double(current) / Double(max) * 100.0
    }
}

