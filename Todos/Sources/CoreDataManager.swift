//
//  CoreDataManager.swift
//  Todos
//
//  Created by Ador on 2020/12/17.
//

import UIKit
import CoreData

class CoreDataManager {
    
    static let shared: CoreDataManager = CoreDataManager()
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var context = appDelegate.persistentContainer.viewContext
    
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T] {
        do {
            let fetchResult = try self.context.fetch(request)
            return fetchResult
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    @discardableResult
    func insertTask(taskName: String, dueDate: Date, completion: (() -> Void)?) -> Bool { // Task 객체로 받을 수 없나?
        
        //let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Task", in: context)
        if let entity = entity {
            let task = NSManagedObject(entity: entity, insertInto: context)
            task.setValue(taskName, forKey: "name")
            task.setValue(dueDate, forKey: "dueDate")
            do {
                try context.save()
                print("Task Insert Success")
                completion?()
            } catch {
                print(error.localizedDescription)
                return false
            }
        }
        return true
    }
    
    @discardableResult
    func deleteTask(object: NSManagedObject, completion: (() -> Void)?) -> Bool {
        self.context.delete(object)
        do{
            try self.context.save()
            print("Task Delete Success")
            completion?()
            return true
        } catch {
            return false
        }
    }
}

