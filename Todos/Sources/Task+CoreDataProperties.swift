//
//  Task+CoreDataProperties.swift
//  Todos
//
//  Created by Ador on 2020/12/17.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var dueDate: Date?
    @NSManaged public var name: String?

}

extension Task : Identifiable {

}
