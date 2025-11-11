//
//  InsightsView.swift
//  MacBatteryMonitor
//
//  Created by Rahul Ravi Prakash on 12/11/25.
//


import SwiftUI
import CoreData

struct InsightsView: View {
    @Environment(\.managedObjectContext) private var context
    
    @FetchRequest(
        entity: BatteryRecord.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \BatteryRecord.timestamp, ascending: true)]
    ) private var records: FetchedResults<BatteryRecord>
    
    @State private var avgCharge: Double = 0
    @State private var avgTemperature: Double = 0
    @State private var totalCycles: Int = 0
    @State private var estimatedHealth: Double = 100
    @State private var healthStatus: String = "Excellent"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                Text("Battery Insights")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                if records.isEmpty {
                    VStack(spacing: 8) {
                        Text("No insights available yet.")
                            .foregroundColor(.secondary)
                        Text("Keep the app running to collect sufficient data.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
                } else {
                    statsSection
                    Divider()
                    healthSection
                    Divider()
                    suggestionsSection
                }
            }
            .padding()
        }
        .onAppear(perform: computeInsights)
    }
}

// MARK: - Computation
private extension InsightsView {
    func computeInsights() {
        guard !records.isEmpty else {
            print("⚠️ No battery records found for insights.")
            avgCharge = 0
            avgTemperature = 0
            totalCycles = 0
            estimatedHealth = 100
            healthStatus = "Unknown"
            return
        }
        
        // Extract values directly (strongly typed)
        let chargeValues = records.map { Double($0.percentage) }
        let tempValues = records.map { $0.temperature }
        let cycleValues = records.map { Int($0.cycleCount) }
        
        // Compute averages safely
        avgCharge = chargeValues.reduce(0, +) / Double(max(chargeValues.count, 1))
        avgTemperature = tempValues.reduce(0, +) / Double(max(tempValues.count, 1))
        totalCycles = cycleValues.last ?? 0
        
        // Estimate health based on trend (optional enhancement)
        if let latest = chargeValues.last, avgCharge > 0 {
            estimatedHealth = min((latest / avgCharge) * 100, 100)
        } else {
            estimatedHealth = 100
        }
        
        // Assign health status
        switch estimatedHealth {
        case 90...100:
            healthStatus = "Excellent"
        case 80..<90:
            healthStatus = "Good"
        case 65..<80:
            healthStatus = "Fair"
        default:
            healthStatus = "Poor"
        }
        
        // Debug log
        print("""
        ✅ Insights computed successfully:
        • Avg Charge: \(String(format: "%.1f", avgCharge))%
        • Avg Temperature: \(String(format: "%.1f", avgTemperature))°C
        • Total Cycles: \(totalCycles)
        • Estimated Health: \(String(format: "%.1f", estimatedHealth))% (\(healthStatus))
        """)
    }
}

// MARK: - Sections
private extension InsightsView {
    var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overall Statistics")
                .font(.headline)
            Grid(horizontalSpacing: 16, verticalSpacing: 12) {
                GridRow {
                    statCard(title: "Avg. Charge", value: String(format: "%.0f %%", avgCharge))
                    statCard(title: "Avg. Temp", value: String(format: "%.1f °C", avgTemperature))
                }
                GridRow {
                    statCard(title: "Total Cycles", value: "\(totalCycles)")
                    statCard(title: "Est. Health", value: String(format: "%.0f %%", estimatedHealth))
                }
            }
        }
    }
    
    var healthSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Battery Health Status")
                .font(.headline)
            HStack {
                Image(systemName: healthIcon)
                    .font(.system(size: 30))
                    .foregroundStyle(healthColor)
                VStack(alignment: .leading) {
                    Text(healthStatus)
                        .font(.title3).bold()
                    Text(healthDescription)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
        }
    }
    
    var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Suggestions")
                .font(.headline)
            
            ForEach(suggestions, id: \.self) { suggestion in
                Label(suggestion, systemImage: "lightbulb")
                    .font(.subheadline)
            }
        }
    }
    
    func statCard(title: String, value: String) -> some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .bold()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemFill)))
    }
}

// MARK: - Dynamic Info
private extension InsightsView {
    var healthColor: Color {
        switch healthStatus {
        case "Excellent": return .green
        case "Good": return .blue
        case "Fair": return .orange
        default: return .red
        }
    }
    
    var healthIcon: String {
        switch healthStatus {
        case "Excellent": return "battery.100"
        case "Good": return "battery.75"
        case "Fair": return "battery.50"
        default: return "battery.25"
        }
    }
    
    var healthDescription: String {
        switch healthStatus {
        case "Excellent": return "Battery capacity is close to new condition."
        case "Good": return "Slight wear detected, but performance is still strong."
        case "Fair": return "Battery shows signs of aging. Consider calibration soon."
        default: return "Battery health is low. Replacement may be needed."
        }
    }
    
    var suggestions: [String] {
        var tips: [String] = []
        if avgTemperature > 40 {
            tips.append("Avoid high temperatures — they degrade the battery faster.")
        }
        if avgCharge > 90 {
            tips.append("Try to keep your charge level between 20–80% for longer lifespan.")
        }
        if totalCycles > 800 {
            tips.append("Your battery has high cycle count — health degradation is expected.")
        }
        if tips.isEmpty {
            tips.append("Battery usage appears balanced. Keep up the good habits!")
        }
        return tips
    }
}
