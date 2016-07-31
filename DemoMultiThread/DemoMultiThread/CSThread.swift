//
//  CSThread.swift
//  DemoMultiThread
//
//  Created by Chris Hu on 15/11/12.
//  Copyright © 2015年 icetime17. All rights reserved.
//

import UIKit

protocol CSThreadCompletionDelegate {
    func csThreadCompletion()
}

class CSThread: NSThread {

    var delegate: CSThreadCompletionDelegate!
    
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
