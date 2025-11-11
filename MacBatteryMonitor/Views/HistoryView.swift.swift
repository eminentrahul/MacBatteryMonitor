//
//  HistoryView.swift.swift
//  MacBatteryMonitor
//
//  Created by Rahul Ravi Prakash on 11/11/25.
//

import SwiftUI
import CoreData

// Make sure BatteryRecord has Identifiable behavior via objectID in ForEach (no source changes needed).
// If you prefer, you can also add `extension BatteryRecord: Identifiable { }` in your project.

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var context

    @FetchRequest(
        entity: BatteryRecord.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \BatteryRecord.timestamp, ascending: false)]
    ) private var records: FetchedResults<BatteryRecord>

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()

    var body: some View {
        List {
            if records.isEmpty {
                VStack(spacing: 8) {
                    Text("No battery history available.")
                        .foregroundColor(.secondary)
                    Text("Keep the app running to collect data.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 40)
            } else {
                ForEach(records, id: \.objectID) { record in
                    HistoryRow(record: record, dateFormatter: dateFormatter)
                }
                .onDelete(perform: deleteRecords)
            }
        }
        .navigationTitle("Battery History")
        
    }

    private func deleteRecords(at offsets: IndexSet) {
        offsets.map { records[$0] }.forEach { r in
            context.delete(r)
        }
        do {
            try context.save()
        } catch {
            print("Failed to delete record:", error)
        }
    }
}

// MARK: - Row View (safe, KVC-backed)
private struct HistoryRow: View {
    let record: BatteryRecord
    let dateFormatter: DateFormatter

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(dateFormatter.string(from: timestamp))
                .font(.headline)

            HStack {
                Label("Charge", systemImage: "battery.100")
                Spacer()
                Text("\(Int(charge))%")
                    .bold()
            }

            HStack {
                Label("Cycle", systemImage: "gauge")
                Spacer()
                Text("\(cycleCount)")
            }

            HStack {
                Label("Temp", systemImage: "thermometer")
                Spacer()
                Text(String(format: "%.1f °C", temperature))
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: - Safe value accessors (try multiple possible attribute names)
    private var timestamp: Date {
        if let d = record.value(forKey: "timestamp") as? Date { return d }
        // fallback
        return Date()
    }

    private var charge: Double {
        // Some code paths used "percentage", others "currentCharge"
        if let n = record.value(forKey: "percentage") as? NSNumber { return n.doubleValue }
        if let d = record.value(forKey: "percentage") as? Double { return d }
        if let n = record.value(forKey: "currentCharge") as? NSNumber { return n.doubleValue }
        if let d = record.value(forKey: "currentCharge") as? Double { return d }
        // fallback to 0
        return 0
    }

    private var cycleCount: Int {
        if let n = record.value(forKey: "cycleCount") as? NSNumber { return n.intValue }
        if let i = record.value(forKey: "cycleCount") as? Int { return i }
        // fallback
        return 0
    }

    private var temperature: Double {
        if let n = record.value(forKey: "temperature") as? NSNumber { return n.doubleValue }
        if let d = record.value(forKey: "temperature") as? Double { return d }
        return 0
    }
}


