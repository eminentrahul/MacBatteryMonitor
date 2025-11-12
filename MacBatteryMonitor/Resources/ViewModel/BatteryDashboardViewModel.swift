//
//  BatteryDashboardViewModel.swift
//  MacBatteryMonitor
//
//  Created by Rahul Ravi Prakash on 11/11/25.
//


import Foundation
import CoreData
import Combine

@MainActor
class BatteryDashboardViewModel: ObservableObject {
    @Published var batteryInfo: BatteryInfo?
    @Published var avgTemperature: Double = 0
    @Published var avgCharge: Double = 0
    @Published var totalCycles: Int = 0
    @Published var records: [BatteryRecord] = []

    private var context: NSManagedObjectContext
    private var timer: Timer?

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchBattery()
        computeInsights()
        startLiveUpdates()
    }

    func startLiveUpdates() {
        stopLiveUpdates()
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            self.fetchBattery()
            self.computeInsights()
        }
    }

    func stopLiveUpdates() {
        timer?.invalidate()
        timer = nil
    }

    func fetchBattery() {
        batteryInfo = BatteryService.getBatteryInfo()
    }

    func computeInsights() {
        let request = NSFetchRequest<BatteryRecord>(entityName: "BatteryRecord")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]

        do {
            let fetched = try context.fetch(request)
            DispatchQueue.main.async {
                self.records = fetched

                let temps: [Double] = fetched.compactMap {
                    if let d = $0.value(forKey: "temperature") as? Double { return d }
                    if let n = $0.value(forKey: "temperature") as? NSNumber { return n.doubleValue }
                    return nil
                }

                let charges: [Double] = fetched.compactMap {
                    if let i = $0.value(forKey: "percentage") as? Int { return Double(i) }
                    if let n = $0.value(forKey: "percentage") as? NSNumber { return n.doubleValue }
                    return nil
                }

                let lastCycle: Int = {
                    guard let last = fetched.last else { return 0 }
                    if let i = last.value(forKey: "cycleCount") as? Int { return i }
                    if let n = last.value(forKey: "cycleCount") as? NSNumber { return n.intValue }
                    return 0
                }()

                self.avgTemperature = temps.isEmpty ? 0 : temps.reduce(0, +) / Double(temps.count)
                self.avgCharge = charges.isEmpty ? 0 : charges.reduce(0, +) / Double(charges.count)
                self.totalCycles = lastCycle
            }
        } catch {
            print("Core Data fetch failed:", error)
        }
    }
}

