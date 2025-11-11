//
//  PersistenceController.swift
//  MacBatteryMonitor
//
//  Created by Rahul Ravi Prakash on 11/11/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "BatteryModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data load failed: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

