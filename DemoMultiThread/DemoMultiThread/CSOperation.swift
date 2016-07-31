//
//  CSOperation.swift
//  DemoMultiThread
//
//  Created by Chris Hu on 15/11/11.
//  Copyright © 2015年 icetime17. All rights reserved.
//

import UIKit

protocol CSOperationCompletionDelegate {
    func csOperationCompletion()
}

// 自定义NSOperation
class CSOperation: NSOperation {
    
    var delegate: CSOperationCompletionDelegate!
    
    override func main() {
        super.main()
        
        sleep(2)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if (self.delegate != nil) {
                self.delegate.csOperationCompletion()
            }
        })
    }
}
