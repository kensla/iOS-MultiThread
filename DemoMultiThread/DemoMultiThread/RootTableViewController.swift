//
//  RootTableViewController.swift
//  DemoMultiThread
//
//  Created by Chris Hu on 15/11/6.
//  Copyright © 2015年 icetime17. All rights reserved.
//

import UIKit

class RootTableViewController: UITableViewController {

    var demos = Array<String>()
    var samplesGCD = Array<String>()
    var samplesNSOperationQueue = Array<String>()
    var samplesNSThreads = Array<String>()
    var samplesThreadSecurity = Array<String>()
    var samplesNSRunLoop = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.demos =                   ["GCD",
                                        "NSOperationQueue",
                                        "NSThread",
                                        "ThreadSecurity",
                                        "NSRunLoop"]
        self.samplesGCD =              ["dispatch_queue_t",
                                        "dispatch_once",
                                        "dispatch_apply",
                                        "dispatch_after",
                                        "dispatch_time",
                                        "dispatch_sync",
                                        "dispatch_async",
                                        "dispatch_group_async",
                                        "dispatch_group_notify",
                                        "dispatch_group_wait",
                                        "dispatch_suspend_resume"]
        self.samplesNSOperationQueue = ["NSOperationQueue",
                                        "CustomOperation",
                                        "addDependency",
                                        "queuePriority",
                                        "maxConcurrentOperationCount",
                                        "cancel_suspended"]
        self.samplesNSThreads =        ["NSThread",
                                        "CustomThread"]
        self.samplesThreadSecurity =   ["Singleton",
                                        "dispatch_barrier_async"]
        self.samplesNSRunLoop = []
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.demos.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.demos[section] as String
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.samplesGCD.count
        case 1:
            return self.samplesNSOperationQueue.count
        case 2:
            return self.samplesNSThreads.count
        case 3:
            return self.samplesThreadSecurity.count
        case 4:
            return self.samplesNSRunLoop.count
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        switch indexPath.section {
        case 0:
            cell.textLabel?.text = self.samplesGCD[indexPath.row]
            break
        case 1:
            cell.textLabel?.text = self.samplesNSOperationQueue[indexPath.row]
            break
        case 2:
            cell.textLabel?.text = self.samplesNSThreads[indexPath.row]
            break
        case 3:
            cell.textLabel?.text = self.samplesThreadSecurity[indexPath.row]
            break
        case 4:
            cell.textLabel?.text = self.samplesNSRunLoop[indexPath.row]
            break
        default:
            cell.textLabel?.text = ""
            break
        }
        return cell
    }

    var sampleSelected: String!
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            self.sampleSelected = self.samplesGCD[indexPath.row]
            break
        case 1:
            self.sampleSelected = self.samplesNSOperationQueue[indexPath.row]
            break
        case 2:
            self.sampleSelected = self.samplesNSThreads[indexPath.row]
            break
        case 3:
            self.sampleSelected = self.samplesThreadSecurity[indexPath.row]
            break
        case 4:
            self.sampleSelected = self.samplesNSRunLoop[indexPath.row]
            break
        default:
            break
        }
        self.performSegueWithIdentifier("CellSegue", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CellSegue" {
            let itemVC = segue.destinationViewController as! ItemViewController
            itemVC.sampleSelected = self.sampleSelected
        }
    }

}
