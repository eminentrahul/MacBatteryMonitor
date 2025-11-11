//
//  BatteryInfo.swift
//  MacBatteryMonitor
//
//  Created by Rahul Ravi Prakash on 11/11/25.
//

import Foundation

struct BatteryInfo {
    var currentCapacity: Int
    var maxCapacity: Int
    var cycleCount: Int
    var temperature: Double
    var voltage: Double
    var isCharging: Bool
    var healthPercentage: Double {
        Double(currentCapacity) / Double(maxCapacity) * 100.0
    }
}
