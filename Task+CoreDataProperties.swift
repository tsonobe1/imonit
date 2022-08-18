//
//  Task+CoreDataProperties.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/05/25.
//
//

import Foundation
import CoreData

extension Task {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }
    @NSManaged public var createdAt: Date?
    @NSManaged public var detail: String?
    @NSManaged public var endDate: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isDone: Bool
    @NSManaged public var startDate: Date?
    @NSManaged public var task: String?
    @NSManaged public var influence: String?
    @NSManaged public var benefit: String?
    @NSManaged public var microTasks: NSSet?
}

// MARK: Generated accessors for microTasks
extension Task {
    @objc(addMicroTasksObject:)
    @NSManaged public func addToMicroTasks(_ value: MicroTask)

    @objc(removeMicroTasksObject:)
    @NSManaged public func removeFromMicroTasks(_ value: MicroTask)

    @objc(addMicroTasks:)
    @NSManaged public func addToMicroTasks(_ values: NSSet)

    @objc(removeMicroTasks:)
    @NSManaged public func removeFromMicroTasks(_ values: NSSet)

}

extension Task: Identifiable {}
