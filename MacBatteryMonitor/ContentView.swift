//
//  ContentView.swift
//  MacBatteryMonitor
//
//  Created by Rahul Ravi Prakash on 11/11/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel: BatteryViewModel

    init() {
        _viewModel = StateObject(wrappedValue: BatteryViewModel())
    }

    var body: some View {
        TabView {
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
            .tabItem { Label("Dashboard", systemImage: "battery.100") }
            
            DashboardView(context: context)
                .tabItem { Label("Dashboard V2", systemImage: "battery.100") }

            HistoryView()
                .tabItem { Label("History", systemImage: "chart.line.uptrend.xyaxis") }
            
            ChartsView()
                    .tabItem { Label("Charts", systemImage: "chart.xyaxis.line") }
            
            InsightsView()
                    .tabItem { Label("Insight", systemImage: "lightbulb") }

        }
        .frame(minWidth: 400, minHeight: 300)
    }
}

#Preview {
    ContentView()
}
