//
//  ContentView.swift
//  MacBatteryMonitor
//
//  Created by Rahul Ravi Prakash on 11/11/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BatteryViewModel()

    var body: some View {
        VStack(spacing: 15) {
            if let info = viewModel.batteryInfo {
                Text("🔋 Battery Status")
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 10)

                Text("Current Charge: \(info.percentage)%")
                Text(String(format: "Health: %.1f%%", info.healthPercentage ?? "0%"))
                Text("Cycle Count: \(info.cycleCount ?? 0)")
                Text(String(format: "Temperature: %.1f°C", info.temperatureC ?? "0"))
                Text(String(format: "Voltage: %.2f V", info.voltageV ?? "0"))
                Text(info.isCharging ? "⚡ Charging" : "🔌 On Battery")
                    .fontWeight(.semibold)
                    .foregroundColor(info.isCharging ? .green : .orange)
            } else {
                ProgressView("Fetching Battery Info…")
            }
        }
        .frame(width: 320, height: 260)
        .padding()
    }
}

#Preview {
    ContentView()
}
