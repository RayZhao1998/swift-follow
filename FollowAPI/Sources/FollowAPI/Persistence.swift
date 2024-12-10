//
//  Persistence.swift
//  FollowAPI
//
//  Created by Ziyuan Zhao on 2024/12/10.
//

import CoreData

public final class PersistenceController: Sendable {
    public static let shared = PersistenceController()
    
    public let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        guard let modelURL = Bundle.module.url(forResource: "Follow", withExtension: "momd") else {
            fatalError("Failed to find model URL")
        }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load model")
        }
        container = NSPersistentContainer(name: "Follow", managedObjectModel: model)
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

