//
//  Student+CoreDataProperties.swift
//  CoreData_TableLink
//
//  Created by 杨昱航 on 2017/9/5.
//  Copyright © 2017年 杨昱航. All rights reserved.
//

import Foundation
import CoreData


extension Student {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Student> {
        return NSFetchRequest<Student>(entityName: "Student")
    }

    @NSManaged public var studentName: String?
    @NSManaged public var studentId: Int16
    @NSManaged public var studentAge: Int16
    @NSManaged public var studentClass: Class?
    @NSManaged public var studentCourses: NSSet?

}

// MARK: Generated accessors for studentCourses
extension Student {

    @objc(addStudentCoursesObject:)
    @NSManaged public func addToStudentCourses(_ value: Course)

    @objc(removeStudentCoursesObject:)
    @NSManaged public func removeFromStudentCourses(_ value: Course)

    @objc(addStudentCourses:)
    @NSManaged public func addToStudentCourses(_ values: NSSet)

    @objc(removeStudentCourses:)
    @NSManaged public func removeFromStudentCourses(_ values: NSSet)

}
