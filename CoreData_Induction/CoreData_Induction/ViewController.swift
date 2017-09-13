//
//  ViewController.swift
//  CoreData_Induction
//
//  Created by 杨昱航 on 2017/9/4.
//  Copyright © 2017年 杨昱航. All rights reserved.
//

import UIKit

import CoreData

//创建数据模型之后，初始化CoreData栈
/*
 1、加载 ManagedObjectModel
 2、创建 PersistentStoreCoordinator(managedObjectModel 告诉persistentStoreCoordinator 数据模型的结构，然后 persistentStoreCoordinator 会根据对应的模型结构创建持久化的本地存储。)
 3、创建 ManagedObjectContext
 
 */

class ViewController: UIViewController {

//MARK: 初始化操作
    
    let manageObjectModel = NSManagedObjectModel.init(contentsOf: Bundle.main.url(forResource: "CoreData_Induction", withExtension: "momd")!)
    
    var persistentStoreCoordinator:NSPersistentStoreCoordinator? = nil
    
    let context = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //创建 coordinator 需要传入 managedObjectModel
        persistentStoreCoordinator = NSPersistentStoreCoordinator.init(managedObjectModel: self.manageObjectModel!)
        
        // 指定本地的 sqlite 数据库文件
        let sqliteUrl = self.documentDirectoryURL().appendingPathComponent("CoreData_Induction.sqlite", isDirectory: false)
        
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
    
//MARK:数据增删改查

    @IBOutlet weak var nameTF: UITextField!

    @IBOutlet weak var ageTF: UITextField!
    
    @IBOutlet weak var idTF: UITextField!
    

    //简单增加
    @IBAction func addData(_ sender: Any) {
        
        let student:Student = NSEntityDescription.insertNewObject(forEntityName: "Student", into: self.context) as! Student
        
        student.studentName = nameTF.text
        student.studentId = Int16(idTF.text!)!
        student.studentAge = Int16(ageTF.text!)!
        
        do {
            try self.context.save()
            print("插入成功")
        } catch {
            print("插入失败")
        }
        
    }
    
    
    //简单查询查
    /*
     NSFetchRequest:查询请求，相当于SQL中的Select
     NSPredicate:谓词，相当于SQL中的Where
     NSSortDescriptor:指定排序规则，相当于 SQL 中的 ORDER BY 子句
     */
    
    var fetchObjects:[Student] = [Student]()
    
    @IBAction func SelectData(_ sender: Any) {
        /*
         NSFetchRequest属性：除predicate，sortDescriptors外,
         fetchLimit — 指定结果集中数据的最大条目数，相当于 SQL 中的 LIMIT 子句
         fetchOffset — 指定查询的偏移量，默认为 0
         fetchBatchSize — 指定批处理查询的大小，设置了这个属性后，查询的结果集会分批返回
         entityName/entity — 指定查询的数据表，相当于 SQL 中的 FROM 语句
         propertiesToGroupBy — 指定分组规则，相当于 SQL 中的 GROUP BY 子句
         propertiesToFetch — 指定要查询的字段，默认会查询全部字段
         */
        
        let fetchRequest:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>.init()
        
        let entity = NSEntityDescription.entity(forEntityName: "Student", in: self.context)
        fetchRequest.entity = entity
        
        let predicate = NSPredicate.init(format: "studentAge > %d", 10)
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor.init(key: "studentName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchObjects = try! self.context.fetch(fetchRequest) as! [Student]
        
        for student in fetchObjects {
             print("\(student.studentAge) + \(student.studentId) + \(String(describing: student.studentName))")
        }
    }
    
    //简单删除
    @IBAction func deleteData(_ sender: Any) {
        
        self.context.delete(fetchObjects[0])
        
        do {
            try self.context.save()
            print("删除一条记录")
        } catch  {
            print("删除失败")
        }
    }
    
    //简单更新
    @IBAction func updateData(_ sender: Any) {
        let student = fetchObjects[0]
        student.studentName = "newName"
        do {
            try self.context.save()
            print("更新一条记录")
        } catch  {
            print("更新失败")
        }
    }
//MARK:增删改查--进阶
    
    //批量插入
    @IBAction func manyAddData(_ sender: Any) {
        for i in 0..<10{
            let newStudent:Student = NSEntityDescription.insertNewObject(forEntityName: "Student", into: self.context) as! Student
            
            newStudent.studentName = String.init(format: "student-%d", i)
            newStudent.studentId = Int16(10000 + i)
            newStudent.studentAge = Int16(20 + i)
        }
        
        do {
            try self.context.save()
            print("插入多条记录")
        } catch  {
            print("插入多条失败")
        }
    }
    
    //批量更新
    @IBAction func manyUpdateData(_ sender: Any) {
        
        //第一种 KVC ,fetchObjects必须为NSMutableArray类型才可用
        //fetchObjects.setValue(<#T##value: Any?##Any?#>, forKey: <#T##String#>)
        
        //第二种NSBatchUpdateRequest 批量更新（iOS 8, macOS 10.10 之后新添加的 API）
        /*
         它是专门用来进行批量更新的。因为用上面那种方式批量更新的话，会存在一个问题，就是更新前需要将要更新的数据，查询出来，加载到内存中；这在数据量非常大的时候，假如说要更新十万条数据，就比较麻烦了，因为对于手机这种内存比较小的设备，直接加载这么多数据到内存里显然是不可能的。解决办法就是每次只查询出读取一小部分数据到内存中，然后对其进行更新，更新完之后，再更新下一批，就这样分批来处理。但这显然不是高效的解决方案。
         
         于是就有了 NSBatchUpdateRequest 这个 API。它的工作原理是不加载到内存里，而是直接对本地数据库中数据进行更新。这就避免了内存不足的问题；但同时，由于是直接更新数据库，所以内存中的 NSManagedObjectContext 不会知道数据库的变化，解决办法是调用 NSManagedObjectContext 的 + (void)mergeChangesFromRemoteContextSave:(NSDictionary*)changeNotificationData intoContexts:(NSArray<NSManagedObjectContext*> *)contexts;方法来告诉 context，有哪些数据更新了。
         */
        let updateRequest = NSBatchUpdateRequest.init(entity: Student.entity())
        //或者let updateRequest = NSBatchUpdateRequest.init(entityName: "Student")
        
        //指定更新条件
        updateRequest.predicate = NSPredicate.init(format: "studentAge == %d", 20)
        
        //开始更新
        updateRequest.propertiesToUpdate = ["studentName":"anotherName"]
        
        /*
         resultType 属性是 NSBatchUpdateRequestResultType 类型的枚举，用来指定返回的数据类型。这个枚举有三个成员：
         NSStatusOnlyResultType — 返回 BOOL 结果，表示更新是否执行成功
         NSUpdatedObjectIDsResultType — 返回更新成功的对象的 ID，是 NSArray\<NSManagedObjectID *\> * 类型。
         NSUpdatedObjectsCountResultType — 返回更新成功数据的总数，是数字类型
         一般我们将其指定为 NSUpdatedObjectIDsResultType
         */
        updateRequest.resultType = .updatedObjectIDsResultType
        
        var updateResult:NSBatchUpdateResult = NSBatchUpdateResult.init()
        
        do {
            try updateResult = self.context.execute(updateRequest) as! NSBatchUpdateResult
            print("批量更新成功")
        } catch {
            print("批量更新失败")
        }
        
        print(updateResult.result!)
        
        //底层数据更新之后，现在要通知内存中的 context 了
        let updatedDict:[AnyHashable:Any] = [NSUpdatedObjectsKey:updateResult.result!]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: updatedDict, into: [self.context])
    }
    
    //批量删除
    /*
     NSBatchDeleteRequest 的用法和 NSBatchUpdateRequest 很相似，不同的是 NSBatchDeleteRequest 需要指定 fetchRequest 属性来进行删除；而且它是 iOS 9 才添加进来的，和 NSBatchUpdateRequest 的适用范围不一样

     */
    @IBAction func manyDeleteData(_ sender: Any) {
        let fetchRequest:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>.init()
        
        let entity = NSEntityDescription.entity(forEntityName: "Student", in: self.context)
        fetchRequest.entity = entity
        
        let predicate = NSPredicate.init(format: "studentAge == %d", 20)
        fetchRequest.predicate = predicate
        
        let deleteRequest = NSBatchDeleteRequest.init(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs
        
        var deleteResult:NSBatchDeleteResult = NSBatchDeleteResult.init()
        
        do {
            try deleteResult = self.context.execute(deleteRequest) as! NSBatchDeleteResult
            print("批量删除成功")
        } catch {
            print("批量删除失败")
        }
        
        print(deleteResult.result!)
        
        //底层数据更新之后，现在要通知内存中的 context 了
        let deleteDict:[AnyHashable:Any] = [NSDeletedObjectsKey:deleteResult.result!]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deleteDict, into: [self.context])
    }
    
}

