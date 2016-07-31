//
//  ItemViewController.swift
//  DemoMultiThread
//
//  Created by Chris Hu on 15/11/6.
//  Copyright © 2015年 icetime17. All rights reserved.
//

import UIKit

class ItemViewController: UIViewController,
CSOperationCompletionDelegate, CSThreadCompletionDelegate {
    
    var sampleSelected: String!
    
    var label: UILabel!
    
    var myArray = Array<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.sampleSelected
        
        self.label = UILabel(frame: CGRectMake(0, 200, self.view.frame.size.width, 50))
        self.label.textAlignment = NSTextAlignment.Center
        self.label.text = "label"
        self.view.addSubview(self.label)
        
        let btn = UIButton(frame: CGRectMake(0, self.view.frame.size.height - 100, self.view.frame.size.width, 50))
        btn.setTitle("Demo", forState: UIControlState.Normal)
        btn.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        btn.setTitleColor(UIColor.redColor(), forState: UIControlState.Highlighted)
        btn.layer.borderColor = UIColor.redColor().CGColor
        btn.layer.borderWidth = 2.0
        btn.addTarget(self, action: #selector(ItemViewController.demos), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(btn)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func demos() {
        switch self.sampleSelected {
            
// MARK: - GCD

        case "dispatch_queue_t":
            // GCD队列: 包含全局队列，主队列，自定义队列
            let myQueue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
//            let myQueue: dispatch_queue_t = dispatch_queue_create("com.chris.threads", DISPATCH_QUEUE_SERIAL)
//            let myQueue: dispatch_queue_t = dispatch_queue_create("com.chris.threads", DISPATCH_QUEUE_CONCURRENT)
            // 异步执行该队列中任务
            dispatch_async(myQueue, { () -> Void in
                self.delayAction()
            })
            break
        case "dispatch_once":
            // 线程安全，常用于单例模式中。
            var onceToken: dispatch_once_t = 0
            dispatch_once(&onceToken, { () -> Void in
                print("\(self.sampleSelected)")
            })
            break
        case "dispatch_apply":
            // 默认是并发运行的，即打印序号是随机排序。同步会阻塞线程，放在dispatch_async包装一下不阻塞线程。
            // 一般用for循环即可。
            dispatch_apply(5, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { (index: Int) -> Void in
                print(index)
                // 并发队列name默认为null
                print(NSThread.currentThread())
            })
            break
        case "dispatch_after":
            // 延时操作一般是用于更新主线程中UI。
            let myTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, (Int64)(NSEC_PER_SEC * 2))
            dispatch_after(myTime, dispatch_get_main_queue(), { () -> Void in
                self.updateLabel()
            })
            break
        case "dispatch_time":
            // 延时操作一般是用于更新主线程中UI
            let myTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, (Int64)(NSEC_PER_SEC * 2))
            dispatch_after(myTime, dispatch_get_main_queue(), { () -> Void in
                self.updateLabel()
            })
            break
        case "dispatch_sync":
            // 一般不用同步操作，会block住。
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                self.delayAction()
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    self.updateLabel()
                })
            })
            break
        case "dispatch_async":
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                // 网络请求等耗时的逻辑计算放在异步线程，以免block住当前UI
                self.delayAction()
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // 在主线程中更新UI
                    self.updateLabel()
                })
            })
            break
        case "dispatch_group_async":
            let myQueue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            
            let myGroup = dispatch_group_create()
            dispatch_group_async(myGroup, myQueue, { () -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // operation 1
                })
            })
            dispatch_group_async(myGroup, myQueue, { () -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //operation 2
                })
            })
            // 异步
            dispatch_group_notify(myGroup, dispatch_get_main_queue(), { () -> Void in
                // operation 3, 会等到myGroup中的任务执行完毕再执行。
            })
            break
        case "dispatch_group_notify":
            let myQueue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            
            let myGroup = dispatch_group_create()
            dispatch_group_async(myGroup, myQueue, { () -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // operation 1
                })
            })
            dispatch_group_async(myGroup, myQueue, { () -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //operation 2
                })
            })
            // 异步
            dispatch_group_notify(myGroup, dispatch_get_main_queue(), { () -> Void in
                // operation 3, 会等到myGroup中的任务执行完毕再执行。
            })
            break
        case "dispatch_group_wait":
            let myQueue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            
            let myGroup = dispatch_group_create()
            dispatch_group_async(myGroup, myQueue, { () -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // operation 1
                })
            })
            dispatch_group_async(myGroup, myQueue, { () -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //operation 2
                })
            })
            // 同步，如操作数据库要等待完成之后才让用户操作其他的
            dispatch_group_wait(myGroup, dispatch_time(DISPATCH_TIME_NOW, (Int64)(NSEC_PER_SEC * 10)))
            break
        case "dispatch_suspend_resume":
            let myQueue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            // 不能暂停系统队列和主队列。
            // 已加入队列的任务不会暂停，而未加入的会暂停。
            dispatch_suspend(myQueue)
//            dispatch_resume(myQueue)
            break
            
// MARK: - NSOperation
            
        case "NSOperationQueue":
            // 添加自定义的队列
            let myOperation = NSBlockOperation(block: { () -> Void in
                self.delayAction()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.updateLabel()
                })
            })
            // 执行完成之后的动作
//            myOperation.completionBlock = { () -> Void in
//                print("CompletionBlock")
//            }

            // 追加第二个任务，但任务直接是并行的。
//            myOperation.addExecutionBlock({ () -> Void in
//                self.delayAction()
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    self.updateLabel()
//                })
//            })
            NSOperationQueue().addOperation(myOperation)

            // 也可以直接使用如下方法（同步）
//            myOperation.start()
//            myOperation.cancel()
            break
        case "CustomOperation":
            let csOperation = CSOperation()
            csOperation.delegate = self
            NSOperationQueue().addOperation(csOperation)
            break
        case "addDependency":
            let myOperation1 = NSBlockOperation(block: { () -> Void in
                print("myOperation1")
            })
            let myOperation2 = NSBlockOperation(block: { () -> Void in
                print("myOperation2")
            })
            // 若不添加依赖关系，则两个任务执行顺序随机。
            myOperation1.addDependency(myOperation2)
//            myOperation1.removeDependency(myOperation2)
            
            // 默认是并行队列
            let myOperationQueue = NSOperationQueue()
            myOperationQueue.addOperation(myOperation1)
            myOperationQueue.addOperation(myOperation2)
            break
        case "queuePriority":
            let myOperation1 = NSBlockOperation(block: { () -> Void in
                print("myOperation1")
            })
            let myOperation2 = NSBlockOperation(block: { () -> Void in
                print("myOperation2")
            })
            // 优先级并不一定等于依赖关系，只是系统调度时候倾向而已。
            // 两次执行的顺序也可能不一样，并非强制排序。
            myOperation1.queuePriority = NSOperationQueuePriority.VeryLow
            myOperation2.queuePriority = NSOperationQueuePriority.VeryHigh
            
            let myOperationQueue = NSOperationQueue()
            myOperationQueue.addOperation(myOperation1)
            myOperationQueue.addOperation(myOperation2)
            break
        case "maxConcurrentOperationCount":
            let myOperation1 = NSBlockOperation(block: { () -> Void in
                print("myOperation1")
            })
            let myOperation2 = NSBlockOperation(block: { () -> Void in
                print("myOperation2")
            })
            
            let myOperationQueue = NSOperationQueue()
            // 该并发队列中，一次只能执行一个任务，所以顺序固定
            myOperationQueue.maxConcurrentOperationCount = 1
            myOperationQueue.addOperation(myOperation1)
            myOperationQueue.addOperation(myOperation2)
            break
        case "cancel_suspended":
            let myOperation1 = NSBlockOperation(block: { () -> Void in
                print("myOperation1")
            })
            
            let myOperationQueue = NSOperationQueue()
            myOperationQueue.addOperation(myOperation1)
//            myOperation1.cancel()
//            myOperationQueue.cancelAllOperations()
//            myOperation1.waitUntilFinished() // 会阻塞主线程
            myOperationQueue.suspended = true // 只能暂停后添加的操作，已添加的不能暂停
            break
            
// MARK: - NSThread
            
        case "NSThread":
            // 新开一个子线程来执行操作
            NSThread.detachNewThreadSelector(#selector(ItemViewController.delayAction), toTarget: self, withObject: nil)
            // 主线程即为main
            print(NSThread.currentThread())
//            NSThread.sleepForTimeInterval(2)
//            NSThread.sleepUntilDate(<#T##date: NSDate##NSDate#>)
            break
        case "CustomThread":
            let csThread = CSThread()
            csThread.delegate = self
            csThread.start()
            break
            
// MARK: - ThreadSecurity
            
        case "Singleton":
            dispatch_async(dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT), { () -> Void in
                // 非线程安全
                let mySingleton = CSSingleton.sharedSingleTon()
                // 线程安全。这才是真正的单例模式
                let mySingleton2 = CSSingleton.sharedSingleTon2()
            })
            dispatch_async(dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT), { () -> Void in
                let mySingleton = CSSingleton.sharedSingleTon()
                let mySingleton2 = CSSingleton.sharedSingleTon2()
            })
            dispatch_async(dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT), { () -> Void in
                let mySingleton = CSSingleton.sharedSingleTon()
                let mySingleton2 = CSSingleton.sharedSingleTon2()
            })
            break
        case "dispatch_barrier_async":
            // 会强制阻塞队列，而只执行指定的任务
            // 因此不能传入global queue或main queue，因其还要做其他事情。
            dispatch_barrier_async(dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT), { () -> Void in
                self.addMyArray(1)
            })
            break
        case "dispatch_semaphore":
            /*
            // will barrier the UI.
            let signal: dispatch_semaphore_t = dispatch_semaphore_create(0)
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                print("execution inside the block ...")
                sleep(10)
                dispatch_semaphore_signal(signal)
            })
            
            print("execution outside the block, waiting ...")
            dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER)
            print("execution outside the block, ok ...")
            */
            
            // will barrier the UI.
            let signal: dispatch_semaphore_t = dispatch_semaphore_create(0)
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                print("execution inside the block ...")
                sleep(10)
                dispatch_semaphore_signal(signal)
                print("execution inside the block : signal...")
            })
            
            print("execution outside the block, waiting ...")
            dispatch_semaphore_wait(signal, dispatch_time(DISPATCH_TIME_NOW, (Int64)(NSEC_PER_SEC * 2)))
            print("execution outside the block, ok ...")
            break
        default:
            break
        }
    }

    func delayAction() {
        print(NSThread.currentThread())
        sleep(5)
        print("DelayAction")
    }
    
    func updateLabel() {
        self.label.text = "Demos"
    }
    
    func addMyArray(i: Int) {
        self.myArray.append(i)
        print(self.myArray)
    }
    
    // MARK - CSOperationCompletionDelegate
    func csOperationCompletion() {
        print("csOperationCompletion")
    }
    
    func csThreadCompletion() {
        print("csThreadCompletion")
    }
}
