//
//  CSSingleton.swift
//  DemoMultiThread
//
//  Created by Chris Hu on 15/11/12.
//  Copyright © 2015年 icetime17. All rights reserved.
//

import UIKit

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
