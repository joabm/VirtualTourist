//
//  DataController.swift
//  VirtualTourist
//
//  Created by Joab Maldonado on 9/23/22.
//

import Foundation
import CoreData

// class instead of struct because it will be accessed by both view controllers
// and we don't want to create copies.

class DataController {
    
    // MARK: Persistent Container setup
    
    //hold persistent container instance
    let persistentContainer:NSPersistentContainer
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    //load the persistent store
    func load(completion: (()-> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext(interval: 3)
            completion?()
        }
    }
    
    //property to access the context
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
}

extension DataController {
    func autoSaveViewContext(interval: TimeInterval = 30) {
        print("autosaving")
        guard interval > 0 else {
            print("cannot set a negative autosave interval")
            return
        }
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
