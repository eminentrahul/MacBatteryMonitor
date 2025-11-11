//
//  HistoryView.swift.swift
//  MacBatteryMonitor
//
//  Created by Rahul Ravi Prakash on 11/11/25.
//

import SwiftUI
import Charts
import CoreData

struct HistoryView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BatteryRecord.timestamp, ascending: true)],
        animation: .easeInOut)
    private var records: FetchedResults<BatteryRecord>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Battery History")
                .font(.title2)
                .bold()
            
            if records.isEmpty {
                Text("No history yet. Keep app running to log data.")
                    .foregroundStyle(.secondary)
            } else {
                Chart(records) { rec in
                    LineMark(
                        x: .value("Time", rec.timestamp ?? Date()),
                        y: .value("Charge %", rec.percentage)
                    )
                    .foregroundStyle(.green)
                    .interpolationMethod(.catmullRom)
                }
                .frame(height: 200)
            }
        }
        .padding()
    }
}
