//
//  ViewController.swift
//  CoreData_ConcurrentOperation
//
//  Created by 杨昱航 on 2017/9/5.
//  Copyright © 2017年 杨昱航. All rights reserved.
//

import UIKit
import CoreData

/*
 通常情况下，CoreData 的增删改查操作都在主线程上执行，那么对数据库的操作就会影响到 UI 操作，这在操作的数据量比较小的时候，执行的速度很快，我们也不会察觉到对 UI 的影响，但是当数据量特别大的时候，再把 CoreData 的操作放到主线程中就会影响到 UI 的流畅性。自然而然地我们就会想到使用后台线程来处理大量的数据操作。
 */

class ViewController: UIViewController {

    //MARK: 初始化操作
    
    let manageObjectModel = NSManagedObjectModel.init(contentsOf: Bundle.main.url(forResource: "CoreData_ConcurrentOperation", withExtension: "momd")!)
    
    var persistentStoreCoordinator:NSPersistentStoreCoordinator? = nil
    
    /*
     CoreData 里使用后台更新数据最常用的方案是一个 persistentStoreCoordinator 持久化存储协调器对应两个 managedObjectContext 管理上下文，NSManagedObjectContext 在创建时，可以传入 ConcurrencyType 来指定 context 的并发类型。
     
     指定 NSMainQueueConcurrencyType 就是我们平时创建的运行在主队列的 context；
     指定成 NSPrivateQueueConcurrencyType 的话，context 就会运行在它所管理的一个私有队列中；
     另外还有 NSConfinementConcurrencyType 是适用于旧设备的并发类型，现在已经被废弃了，所以实际上只有两种并发类型。
     */
    var backgroundContext = NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType)
    
    let mainContext = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //MARK:在最新的 iOS 10 中，CoreData 栈的创建被封装在了 NSPersistentContainer 类中，用它来创建 backgroundContext 更加简单：
        //let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        //self.context = appDelegate.persistentContainer.newBackgroundContext()
        
        //创建 coordinator 需要传入 managedObjectModel
        persistentStoreCoordinator = NSPersistentStoreCoordinator.init(managedObjectModel: self.manageObjectModel!)
        
        // 指定本地的 sqlite 数据库文件
        let sqliteUrl = self.documentDirectoryURL().appendingPathComponent("CoreData_ConcurrentOperation.sqlite", isDirectory: false)
        
        print(sqliteUrl)
        
        // 为 persistentStoreCoordinator 指定本地存储的类型，这里指定的是 SQLite
        
        do {
            try persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: sqliteUrl, options: nil)
        } catch {
            print("falied to create persistentStoreCoordinator")
        }
        
        mainContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        backgroundContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        //MARK:通知主线程
        /*
         后台插入数据之后，还没有完，因为数据是通过后台的 context 写入到本地的持久化数据库的，所以这时候主队列的 context 是不知道本地数据变化的，所以还需要通知到主队列的 context：“数据库的内容有变化啦，看看你有没有需要合并的”。
         这个过程可以通过监听一条通知来实现。NSManagedObjectContextDidSaveNotification，在每次调用 NSManagedObjectContext 的 save:方法时都会自动发送，通知中的 userInfo 中包含了修改的数据，可以通过 NSInsertedObjectsKey、NSUpdatedObjectsKey、 NSDeletedObjectsKey 这三个 key 获取到
         */
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.receiveContextSave(note:)), name:NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
    }
    
    //获取document目录
    func documentDirectoryURL() -> URL {
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    //主线程保存context
    func receiveContextSave(note:Notification){
        
        let context:NSManagedObjectContext = note.object as! NSManagedObjectContext
        // 这里需要做判断操作，判断当前改变的context是否我们将要做同步的context，如果就是当前context自己做的改变，那就不需要再同步自己了。
        // 由于项目中可能存在多个persistentStoreCoordinator，所以下面还需要判断persistentStoreCoordinator是否当前操作的persistentStoreCoordinator，如果不是当前persistentStoreCoordinator则不需要同步，不要去同步其他本地存储的数据。
        context.perform {
            // 直接调用系统提供的同步API，系统内部会完成同步的实现细节。
            context.mergeChanges(fromContextDidSave: note)
        }
    }

    //MARK:后台插入数据
    
    @IBAction func backgroundInsertData(_ sender: Any) {
        self.backgroundContext.perform {
            for i in 0..<100{
                let newStudent:Student = NSEntityDescription.insertNewObject(forEntityName: "Student", into: self.backgroundContext) as! Student
                
                newStudent.studentName = String.init(format: "student-%d", i)
                newStudent.studentId = Int16(i)
                newStudent.studentAge = Int16(i)
            }
            
            do {
                try self.backgroundContext.save()
                print("插入多条记录")
            } catch  {
                print("插入多条失败")
            }
        }
    }
    
    //查询全部数据
    
    var fetchObjects:[Student] = [Student]()
    
    @IBAction func selectAllData(_ sender: Any) {
        let fetchRequest:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>.init()
        
        let entity = NSEntityDescription.entity(forEntityName: "Student", in: self.mainContext)
        fetchRequest.entity = entity
        
        let predicate = NSPredicate.init(format: "studentAge >= %d", 0)
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor.init(key: "studentName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchObjects = try! self.mainContext.fetch(fetchRequest) as! [Student]
        
        for student in fetchObjects {
            print("\(student.studentAge) + \(student.studentId) + \(String(describing: student.studentName))")
        }
    }
    

}

