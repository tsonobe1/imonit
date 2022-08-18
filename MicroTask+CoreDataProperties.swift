//
//  MicroTask+CoreDataProperties.swift
//  imonit
//
//  Created by 薗部拓人 on 2022/05/25.
//
//

import Foundation
import CoreData

extension MicroTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MicroTask> {
        return NSFetchRequest<MicroTask>(entityName: "MicroTask")
    }

    @NSManaged public var actualDifficultyLevel: Int16
    @NSManaged public var actualexpectedSatisfied: Int16
    @NSManaged public var createdAt: Date?
    @NSManaged public var detail: String?
    @NSManaged public var expectedDifficultyLevel: Int16
    @NSManaged public var expectedSatisfied: Int16
    @NSManaged public var feedback: String?
    @NSManaged public var id: UUID?
    @NSManaged public var isDone: Bool
    @NSManaged public var microTask: String?
    @NSManaged public var order: Int16
    @NSManaged public var timer: Int16
    @NSManaged public var timeTaken: Int64
    @NSManaged public var task: Task?

}

extension MicroTask: Identifiable {

}
