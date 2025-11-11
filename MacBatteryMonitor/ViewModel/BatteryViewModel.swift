//
//  BatteryViewModel.swift
//  MacBatteryMonitor
//
//  Created by Rahul Ravi Prakash on 11/11/25.
//


import Foundation
import Combine

class BatteryViewModel: ObservableObject {
    @Published var batteryInfo: BatteryInfo?
    private var timer: AnyCancellable?

    init() {
        startMonitoring()
    }

    func startMonitoring() {
        timer = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.batteryInfo = BatteryService.getBatteryInfo()
            }
    }
}
