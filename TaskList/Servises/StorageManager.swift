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
    
    lazy var context = StorageManager.shared.persistentContainer.viewContext
    
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
    
    func fetchData(_ completion: (Result<[Task], Error>) -> Void) {
        let fetchRequest = Task.fetchRequest()
        
        do {
            let taskList = try context.fetch(fetchRequest)
            completion(.success(taskList))
        } catch let error {
            completion(.failure(error))
        }
    }
    
// MARK: - Core Data Saving support
    func saveContext () {
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
