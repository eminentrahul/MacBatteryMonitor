//
//  DashboardView.swift
//  MacBatteryMonitor
//
//  Created by Rahul Ravi Prakash on 11/11/25.
//


import SwiftUI
import Charts
import CoreData

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel: BatteryDashboardViewModel

    // FetchRequest replaces @Query for Core Data
    @FetchRequest(
        entity: BatteryRecord.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \BatteryRecord.timestamp, ascending: true)]
    ) private var records: FetchedResults<BatteryRecord>

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: BatteryDashboardViewModel(context: context))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: Header
                headerSection

                Divider()

                // MARK: Stats Grid
                statsGrid

                Divider()

                // MARK: Charge History Chart
                chargeChart

                Divider()

                // MARK: Insights
                insightsSection
            }
            .padding()
        }
        .navigationTitle("Battery Dashboard")
        .onAppear {
            viewModel.computeInsights()
            viewModel.startLiveUpdates()
        }
        .onDisappear {
            viewModel.stopLiveUpdates()
        }
    }
}

private extension DashboardView {
    // MARK: Header Section
    var headerSection: some View {
        VStack {
            if let info = viewModel.batteryInfo {
                HStack {
                    Image(systemName: batteryIcon(for: Double(info.percentage)))
                        .font(.system(size: 48))
                        .foregroundStyle(.green)

                    VStack(alignment: .leading) {
                        Text("\(Int(info.percentage))% Charged")
                            .font(.largeTitle).bold()
                        Text("Max Capacity: \(Int(info.maxMah ?? 0)) mAh")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                ProgressView("Loading Battery Info…")
            }
        }
        .frame(maxWidth: .infinity)
    }

    func batteryIcon(for charge: Double) -> String {
        switch charge {
        case 0..<20: return "battery.0"
        case 20..<40: return "battery.25"
        case 40..<60: return "battery.50"
        case 60..<80: return "battery.75"
        default: return "battery.100"
        }
    }
}

private extension DashboardView {
    // MARK: Stats Grid
    var statsGrid: some View {
        Group {
            if let info = viewModel.batteryInfo {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    statCard("Cycle Count", value: "\(info.cycleCount ?? 0)")
                    statCard("Voltage", value: String(format: "%.2f V", info.voltageV ?? 0.0))
                    statCard("Temperature", value: String(format: "%.1f °C", info.temperatureC ?? 0.0))
                    statCard("Design Capacity", value: String(format: "%.0f mAh", info.maxMah ?? 0))
                }
            } else {
                EmptyView()
            }
        }
    }
    func statCard(_ title: String, value: String) -> some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline).bold()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemFill)))
    }
}

private extension DashboardView {
    // MARK: Charge History Chart
    var chargeChart: some View {
        VStack(alignment: .leading) {
            Text("Charge History")
                .font(.headline)

            if records.isEmpty {
                Text("No logged data yet.")
                    .foregroundStyle(.secondary)
                    .padding(.top)
            } else {
                Chart {
                    ForEach(records, id: \.objectID) { record in
                        if let timestamp = record.timestamp {
                            LineMark(
                                x: .value("Time", timestamp),
                                y: .value("Charge %", record.percentage)
                            )
                            .foregroundStyle(.green)
                            .interpolationMethod(.catmullRom)
                        }
                    }
                }
                .frame(height: 200)
            }
        }
    }
}

private extension DashboardView {
    // MARK: Insights
    var insightsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Insights")
                .font(.headline)

            if records.isEmpty {
                Text("Collecting data for insights…")
                    .foregroundStyle(.secondary)
            } else {
                Text("• Avg Temperature: \(String(format: "%.1f °C", viewModel.avgTemperature))")
                Text("• Avg Charge: \(String(format: "%.0f %%", viewModel.avgCharge))")
                Text("• Total Cycles: \(viewModel.totalCycles)")
            }
        }
    }
}
