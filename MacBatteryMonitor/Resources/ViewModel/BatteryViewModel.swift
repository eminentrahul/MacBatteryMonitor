//
//  BatteryViewModel.swift
//  MacBatteryMonitor
//
//  Created by Rahul Ravi Prakash on 11/11/25.
//


import Foundation
import Combine
import CoreData

class BatteryViewModel: ObservableObject {
    @Published var batteryInfo: BatteryInfo?
    private var timer: AnyCancellable?
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        startMonitoring()
    }

    private func startMonitoring() {
        timer = Timer.publish(every: 300, on: .main, in: .common) // every 5 min
            .autoconnect()
            .sink { _ in
                self.refreshBattery()
            }
        
        refreshBattery() // immediate first run
    }
    
    private func refreshBattery() {
        if let info = BatteryService.getBatteryInfo() {
            self.batteryInfo = info
            saveRecord(info)
        }
    }
    
    private func saveRecord(_ info: BatteryInfo) {
        let record = BatteryRecord(context: context)
        record.timestamp = Date()
        record.percentage = Int16(info.percentage)
        record.voltage = info.voltageV ?? 0
        record.temperature = info.temperatureC ?? 0
        record.cycleCount = Int16(info.cycleCount ?? 0)
        try? context.save()
    }
}
