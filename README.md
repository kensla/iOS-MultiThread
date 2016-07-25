## DemoMultiThread

Demo for iOS Multi threads, including GCD, NSOperationQueue, NSThread, NSRunLoop.

### GCD

请参考博客:[iOS --- 多线程之GCD](http://blog.csdn.net/icetime17/article/details/50405474)

#### dispatch_queue_t
```
// let myQueue: dispatch_queue_t = dispatch_queue_create("com.chris.threads", DISPATCH_QUEUE_SERIAL)
// let myQueue: dispatch_queue_t = dispatch_queue_create("com.chris.threads", DISPATCH_QUEUE_CONCURRENT)
let myQueue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
// 异步执行该队列中任务
dispatch_async(myQueue, { () -> Void in
    self.delayAction()
})
```

#### dispatch_once
```
// 线程安全，常用于单例模式中。
var onceToken: dispatch_once_t = 0
dispatch_once(&onceToken, { () -> Void in
    print("\(self.sampleSelected)")
})
```

#### dispatch_apply
```
dispatch_apply(5, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { (index: Int) -> Void in
    print(NSThread.currentThread())
})
```

#### dispatch_time与dispatch_after
```
let myTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, (Int64)(NSEC_PER_SEC * 2))
dispatch_after(myTime, dispatch_get_main_queue(), { () -> Void in
    self.updateLabel()
})
```

#### dispatch_sync
```
// 一般不用同步操作，可能会block住主线程。
dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
    self.delayAction()
    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
        self.updateLabel()
    })
})
```

#### dispatch_async
最常见的GCD用法:
```
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
    // 网络请求等耗时的逻辑计算放在异步线程，以免block住当前UI
    self.delayAction()

    dispatch_async(dispatch_get_main_queue(), { () -> Void in
        // 在主线程中更新UI
        self.updateLabel()
    })
})
```

#### dispatch_group_async与dispatch_group_notify
```
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
    // operation 3, 会等到myGroup中的任务执行完毕再执行.
})
```

#### dispatch_group_wait
```
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
```

#### dispatch_suspend_resume
```
let myQueue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
// 不能暂停系统队列和主队列。
// 已加入队列的任务不会暂停，而未加入的会暂停。
dispatch_suspend(myQueue)
// dispatch_resume(myQueue)
```

#### dispatch_barrier_async
// 会强制阻塞队列，而只执行指定的任务
// 因此不能传入global queue或main queue，因其还要做其他事情。
```
dispatch_barrier_async(dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT), { () -> Void in
    self.addMyArray(1)
})
```

### NSOperationQueue

请参考博客:[iOS --- 多线程之NSOperation](http://blog.csdn.net/icetime17/article/details/50413608)

#### NSBlockOperation
```
// 添加自定义的队列
let myOperation = NSBlockOperation(block: { () -> Void in
    self.delayAction()
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.updateLabel()
    })
})
NSOperationQueue().addOperation(myOperation)
```

#### addDependency
```
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
```

#### queuePriority
```
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
```

#### maxConcurrentOperationCount
```
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
```

#### cancel与suspend
```
let myOperation1 = NSBlockOperation(block: { () -> Void in
    print("myOperation1")
})

let myOperationQueue = NSOperationQueue()
myOperationQueue.addOperation(myOperation1)
// myOperation1.cancel()
// myOperationQueue.cancelAllOperations()
// myOperation1.waitUntilFinished() // 会阻塞主线程
myOperationQueue.suspended = true // 只能暂停后添加的操作，已添加的不能暂停
```

### NSThread

请参考博客:[iOS --- 多线程之NSThread](http://blog.csdn.net/icetime17/article/details/50405259)

#### detachNewThreadSelector
```
// 新开一个子线程来执行操作
NSThread.detachNewThreadSelector(Selector("delayAction"), toTarget: self, withObject: nil)
// 主线程即为main
print(NSThread.currentThread())
```

#### 自定义NSThread
```
class CSThread: NSThread {

    var delegate: CSThreadCompletionDelegate!

    // 重写main方法, 即线程执行内容
    override func main() {
        super.main()

        sleep(2)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if (self.delegate != nil) {
                self.delegate.csThreadCompletion()
            }
        })
    }
}
```
使用:
```
let csThread = CSThread()
csThread.delegate = self
csThread.start()
```

### NSRunLoop

### 线程安全

#### 单例模式
```
class CSSingleton: NSObject {
    class func sharedSingleTon() -> CSSingleton {

        struct temps {
            static var instance: CSSingleton?
        }

        // 会运行三次
        if temps.instance == nil {
            NSThread.sleepForTimeInterval(2)

            temps.instance = CSSingleton()
            print("\(temps.instance!)")
        }

        return temps.instance!
    }

    class func sharedSingleTon2() -> CSSingleton {

        struct temps {
            static var instance: CSSingleton?
            static var onceToken: dispatch_once_t = 0
        }
        // 只运行一次，线程安全。
        dispatch_once(&temps.onceToken) { () -> Void in
            NSThread.sleepForTimeInterval(2)

            temps.instance = CSSingleton()
            print("\(temps.instance!)")
        }

        return temps.instance!
    }
}
```
使用:
```
dispatch_async(dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT), { () -> Void in
    // 非线程安全
    let mySingleton = CSSingleton.sharedSingleTon()
    // 线程安全。这才是真正的单例模式
    let mySingleton2 = CSSingleton.sharedSingleTon2()
})
```
