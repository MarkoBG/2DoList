//
//  StorageController.swift
//  2DoList
//
//  Created by Marko Tribl on 1/6/18.
//  Copyright © 2018 Marko Tribl. All rights reserved.
//

import Foundation
import CoreData

class StorageController {

    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func save() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func fetchData<T: NSManagedObject>(with request: NSFetchRequest<NSFetchRequestResult> = T.fetchRequest()) -> [T] {
        
        do {
            let items = try context.fetch(request)
            return items as! [T]
        } catch {
            print("Error fetching data from context: \(error)")
            return []
        }
    }
    
    func delete<T: NSManagedObject>(item: T) {
        context.delete(item)
        save()
    }
    
}
