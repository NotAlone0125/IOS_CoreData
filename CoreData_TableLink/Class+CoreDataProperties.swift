//
//  Class+CoreDataProperties.swift
//  CoreData_TableLink
//
//  Created by 杨昱航 on 2017/9/5.
//  Copyright © 2017年 杨昱航. All rights reserved.
//

import Foundation
import CoreData


extension Class {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Class> {
        return NSFetchRequest<Class>(entityName: "Class")
    }

    @NSManaged public var classId: Int16
    @NSManaged public var clazzName: String?
    @NSManaged public var classStudents: Student?

}
