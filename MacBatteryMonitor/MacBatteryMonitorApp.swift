//
//  MacBatteryMonitorApp.swift
//  MacBatteryMonitor
//
//  Created by Rahul Ravi Prakash on 11/11/25.
//

import SwiftUI
import IOKit.ps

@main
struct MacBatteryMonitorApp: App {
    let persistence = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}
