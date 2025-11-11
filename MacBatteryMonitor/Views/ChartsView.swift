//
//  ChartsView.swift
//  MacBatteryMonitor
//
//  Created by Rahul Ravi Prakash on 12/11/25.
//


import SwiftUI
import Charts
import CoreData

struct ChartsView: View {
    @Environment(\.managedObjectContext) private var context
    
    // Fetch all BatteryRecord entries sorted by time
    @FetchRequest(
        entity: BatteryRecord.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \BatteryRecord.timestamp, ascending: true)]
    ) private var records: FetchedResults<BatteryRecord>
    
    @State private var selectedMetric: MetricType = .charge
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // MARK: - Header
            Text("Battery Trends")
                .font(.largeTitle)
                .bold()
            
            // MARK: - Metric Picker
            Picker("Metric", selection: $selectedMetric) {
                ForEach(MetricType.allCases, id: \.self) { metric in
                    Text(metric.title).tag(metric)
                }
            }
            .pickerStyle(.segmented)
            
            // MARK: - Chart Section
            if records.isEmpty {
                VStack {
                    Spacer()
                    Text("No data available yet.")
                        .foregroundColor(.secondary)
                    Text("Keep the app running to collect records.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                Chart {
                    ForEach(records, id: \.objectID) { record in
                        if let date = record.timestamp {
                            LineMark(
                                x: .value("Time", date),
                                y: .value(selectedMetric.title, selectedMetric.value(for: record))
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(selectedMetric.color)
                            
                            PointMark(
                                x: .value("Time", date),
                                y: .value(selectedMetric.title, selectedMetric.value(for: record))
                            )
                            .foregroundStyle(selectedMetric.color.opacity(0.8))
                            .symbolSize(20)
                        }
                    }
                }
                .chartYAxisLabel(position: .trailing) {
                    Text(selectedMetric.unit)
                }
                .frame(height: 280)
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Charts")
    }
}

// MARK: - Metric Enum
enum MetricType: CaseIterable {
    case charge, temperature, voltage
    
    var title: String {
        switch self {
        case .charge: return "Charge %"
        case .temperature: return "Temperature"
        case .voltage: return "Voltage"
        }
    }
    
    var color: Color {
        switch self {
        case .charge: return .green
        case .temperature: return .orange
        case .voltage: return .blue
        }
    }
    
    var unit: String {
        switch self {
        case .charge: return "%"
        case .temperature: return "°C"
        case .voltage: return "V"
        }
    }
    
    func value(for record: BatteryRecord) -> Double {
        switch self {
        case .charge:
            if let n = record.value(forKey: "percentage") as? NSNumber { return n.doubleValue }
            if let d = record.value(forKey: "currentCharge") as? Double { return d }
            return 0
        case .temperature:
            if let n = record.value(forKey: "temperature") as? NSNumber { return n.doubleValue }
            return 0
        case .voltage:
            if let n = record.value(forKey: "voltage") as? NSNumber { return n.doubleValue }
            return 0
        }
    }
}
