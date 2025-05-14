//
//  CoreDataManager.swift
//  Movies App (Inshorts)
//
//  Created by Banavath UdayKiran Naik on 09/05/25.
//

import CoreData

class CoreDataManager {
    public static let sharedInstance = CoreDataManager()
    private var persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "MoviesModel")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load core data model: \(error)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error in saving changes to CoreData: \(error)")
            }
        }
    }
    
    func fetchData<T: NSManagedObject>(ofType: T.Type) -> [T] {
        let fetchRequest: NSFetchRequest<T> = NSFetchRequest(entityName: String(describing: T.self))
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error in fetching Data: \(error)")
        }
        return []
    }
}
