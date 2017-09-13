//
//  ViewController.swift
//  CoreData_TableLink
//
//  Created by 杨昱航 on 2017/9/5.
//  Copyright © 2017年 杨昱航. All rights reserved.
//

import UIKit

import CoreData
/*
 三张表的关系：
 Student 里有一个 studentClass 字段代表学生所属的班级，一个 studentCourses 字段代表学生在学的所有课程；
 
 Class 里有一个 classStudents 字段代表班级里所有的学生；Course 里有一个 courseStudents 代表学习这门课程的所有学生。可以看出来，这几个字段都是彼此关联的关系。根据上面说的，我们需要用 relationships 来创建这些关联的字段。
 */
//http://www.jianshu.com/p/f298f5076384

/*
 删除规则（Delete Rule）规定了这条数据删除时，它所关联的数据该执行什么样的操作。这里有四种规则可以选择(以学生、班级、课程为例)：
 No Action、Nullify、Cascade、Deny
 
 假如我们删除一名学生：
 1.如果设置成 No Action，它表示不做任何，这个时候学生所在的班级（Class.classStudents）依然会以为这名学生还在这个班级里，同时课程记录里也会以为学习这门课程（Course.courseStudents）的所有学生们里，还有这位学生，当我们访问到这两个属性时，就会出现异常情况，所以不建议设置这个规则；
 2.如果设置成 Nullify，对应的，班级信息里就会把这名学生除名，课程记录里也会把这名学生的记录删除掉；
 3.如果设置成 Cascade，它表示级联操作，这个时候，会把这个学生关联的班级以及课程，一股脑的都删除掉，如果 Clazz 和 Course 里还关联着其他的表，而且也设置成 Cascade 的话，就还会删除下去；
 4.如果设置成 Deny，只有在学生关联的班级和课程都为 nil的情况下，这个学生才能被删除，否则，程序就会抛出异常。
 */

class ViewController: UIViewController {

    //MARK: 初始化操作
    
    let manageObjectModel = NSManagedObjectModel.init(contentsOf: Bundle.main.url(forResource: "CoreData_TableLink", withExtension: "momd")!)
    
    var persistentStoreCoordinator:NSPersistentStoreCoordinator? = nil
    
    let context = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //创建 coordinator 需要传入 managedObjectModel
        persistentStoreCoordinator = NSPersistentStoreCoordinator.init(managedObjectModel: self.manageObjectModel!)
        
        // 指定本地的 sqlite 数据库文件
        let sqliteUrl = self.documentDirectoryURL().appendingPathComponent("CoreData_TableLink.sqlite", isDirectory: false)
        
        print(sqliteUrl)
        
        // 为 persistentStoreCoordinator 指定本地存储的类型，这里指定的是 SQLite
        
        do {
            try persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: sqliteUrl, options: nil)
        } catch {
            print("falied to create persistentStoreCoordinator")
        }
        
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
    }
    
    //获取document目录
    func documentDirectoryURL() -> URL {
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }

//MARK:关联操作
    @IBAction func addData(_ sender: Any) {
        
        //生成Student实例
        let student:Student = NSEntityDescription.insertNewObject(forEntityName: "Student", into: self.context) as! Student
        
        student.studentName = String.init(format: "student-%d", 1)
        student.studentId = 10000
        student.studentAge = 20
        
        
        //生成Class实例
        let classes:Class = NSEntityDescription.insertNewObject(forEntityName: "Class", into: self.context) as! Class
        
        classes.classId = 1
        classes.clazzName = "三年六班"
        
        //学生关联班级
        student.studentClass = classes
        
        //生成Course实例
        let english:Course = NSEntityDescription.insertNewObject(forEntityName: "Course", into: self.context) as! Course
        english.chapterCount = 10
        english.courseId = 1
        english.courseName = "英语"
        
        let math:Course = NSEntityDescription.insertNewObject(forEntityName: "Course", into: self.context) as! Course
        math.chapterCount = 10
        math.courseId = 2
        math.courseName = "数学"
        
        //学生关联课程
        student.addToStudentCourses(NSSet.init(array: [english,math]))
        
        do {
            try self.context.save()
            print("插入记录")
        } catch  {
            print("插入失败")
        }
    }
    
    //查询数据
    @IBAction func selectData(_ sender: Any) {
        
    }
    
}

