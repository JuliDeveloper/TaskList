//
//  StorageManager.swift
//  TaskList
//
//  Created by Julia Romanenko on 07.07.2022.
//

import UIKit
import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
// MARK: - Core Data stack
 
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private init() {}

    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }
    
// MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
