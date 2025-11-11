//
//  BatteryTrendsView.swift
//  MacBatteryMonitor
//
//  Created by Rahul Ravi Prakash on 12/11/25.
//


import SwiftUI
import Charts
import CoreData

enum MetricTab: CaseIterable {
    case voltage, temperature, cycleCount, percentage, health
    
    var title: String {
        switch self {
        case .voltage: return "Voltage"
        case .temperature: return "Temp"
        case .cycleCount: return "Cycle"
        case .percentage: return "Charge"
        case .health: return "Health"
        }
    }
}

struct BatteryTrendsView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BatteryRecord.timestamp, ascending: true)]
    ) private var records: FetchedResults<BatteryRecord>
    
    @State private var selectedTab: MetricTab = .voltage
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Battery Trends Dashboard")
                .font(.title2.bold())
                .padding(.top)
            
            Picker("Metric", selection: $selectedTab) {
                ForEach(MetricTab.allCases, id: \.self) { tab in
                    Text(tab.title).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            ScrollView {
                switch selectedTab {
                case .voltage:
                    VoltageChart(records: records)
                case .temperature:
                    TemperatureChart(records: records)
                case .cycleCount:
                    CycleCountChart(records: records)
                case .percentage:
                    PercentageChart(records: records)
                case .health:
                    HealthChart(records: records)
                }
            }
        }
        .padding(.bottom)
    }
}

struct VoltageChart: View {
    var records: FetchedResults<BatteryRecord>
    
    var body: some View {
        Chart {
            ForEach(records) { rec in
                LineMark(
                    x: .value("Time", rec.timestamp ?? Date()),
                    y: .value("Voltage", rec.voltage)
                )
                .foregroundStyle(.blue)
            }
        }
        .chartYAxisLabel("Voltage (V)")
        .frame(height: 250)
        .padding()
    }
}

struct TemperatureChart: View {
    var records: FetchedResults<BatteryRecord>
    
    var body: some View {
        Chart {
            ForEach(records) { rec in
                LineMark(
                    x: .value("Time", rec.timestamp ?? Date()),
                    y: .value("Temp", rec.temperature)
                )
                .foregroundStyle(.orange)
            }
        }
        .chartYAxisLabel("°C")
        .frame(height: 250)
        .padding()
    }
}

struct CycleCountChart: View {
    var records: FetchedResults<BatteryRecord>
    
    var body: some View {
        Chart {
            ForEach(records) { rec in
                LineMark(
                    x: .value("Time", rec.timestamp ?? Date()),
                    y: .value("Cycle Count", Double(rec.cycleCount))
                )
                .foregroundStyle(.purple)
            }
        }
        .chartYAxisLabel("Cycles")
        .frame(height: 250)
        .padding()
    }
}

struct PercentageChart: View {
    var records: FetchedResults<BatteryRecord>
    
    var body: some View {
        Chart {
            ForEach(records) { rec in
                LineMark(
                    x: .value("Time", rec.timestamp ?? Date()),
                    y: .value("Charge %", Double(rec.percentage))
                )
                .foregroundStyle(.green)
            }
        }
        .chartYAxisLabel("% Charge")
        .frame(height: 250)
        .padding()
    }
}

struct HealthChart: View {
    var records: FetchedResults<BatteryRecord>
    
    private var healthData: [HealthPoint] {
        // Compute approximate health (based on min & max charge)
        let maxCharge = Double(records.map(\.percentage).max() ?? 100)
        let designCharge = 100.0
        let healthPercent = min(100, (maxCharge / designCharge) * 100)
        
        return records.map {
            HealthPoint(timestamp: $0.timestamp ?? Date(), health: healthPercent)
        }
    }
    
    var body: some View {
        Chart {
            ForEach(healthData) { point in
                LineMark(
                    x: .value("Time", point.timestamp),
                    y: .value("Health %", point.health)
                )
                .foregroundStyle(.pink)
            }
        }
        .chartYAxisLabel("Health %")
        .frame(height: 250)
        .padding()
    }
}

struct HealthPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let health: Double
}
