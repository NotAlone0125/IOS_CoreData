//
//  Course+CoreDataProperties.swift
//  CoreData_TableLink
//
//  Created by 杨昱航 on 2017/9/5.
//  Copyright © 2017年 杨昱航. All rights reserved.
//

import Foundation
import CoreData


extension Course {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Course> {
        return NSFetchRequest<Course>(entityName: "Course")
    }

    @NSManaged public var chapterCount: Int16
    @NSManaged public var courseId: Int16
    @NSManaged public var courseName: String?
    @NSManaged public var courseStudents: Student?

}
