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
            completion?()
        }
    }
    
    //property to access the context
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
}
