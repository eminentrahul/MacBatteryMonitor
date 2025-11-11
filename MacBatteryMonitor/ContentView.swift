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
            
            DashboardView(context: context)
                .tabItem { Label("Dashboard", systemImage: "battery.100") }
            
            BatteryTrendsView()
                .tabItem { Label("Battery Trend", systemImage: "battery.100") }
            
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
