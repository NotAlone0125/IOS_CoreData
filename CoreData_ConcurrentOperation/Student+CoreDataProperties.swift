//
//  Student+CoreDataProperties.swift
//  CoreData_ConcurrentOperation
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

    @NSManaged public var studentId: Int16
    @NSManaged public var studentAge: Int16
    @NSManaged public var studentName: String?

}
