//
//  TasksTableViewController.swift
//  DatafromFile
//
//  Created by Jon Vogel on 12/17/14.
//  Copyright (c) 2014 Jon Vogel. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TasksTableViewController: UITableViewController {
    
    var MyManagedObjectContext: NSManagedObjectContext?
    var selectedAOOasString: String?
    var selectedAOO: NSManagedObject?
    var arrayOfTasks: [NSManagedObject]?
    var taskToPass: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAOO()
        fetchTasks()
        
        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfTasks!.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var Cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        var currentTasks = arrayOfTasks![indexPath.row]
        Cell.textLabel?.text = currentTasks.valueForKey("phrase") as String?
        return Cell
    }
    
    func fetchTasks(){
        var fetchRequest = NSFetchRequest(entityName: "Tasks")
        var p = NSPredicate(format: "aoo.phrase == %@", selectedAOO!.valueForKey("phrase") as String)
        fetchRequest.predicate = p
        let sort = NSSortDescriptor(key: "phrase", ascending: true, selector: "localizedStandardCompare:")
        fetchRequest.sortDescriptors = [sort]
        if let fetchResults = MyManagedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as [NSManagedObject]? {
            arrayOfTasks = fetchResults
            
        }
    }
    
    func setAOO () {
        let fetchRequest = NSFetchRequest(entityName: "AOOs")
        let p = NSPredicate(format: "phrase == %@", selectedAOOasString!)
        if let fetchResults = MyManagedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as [NSManagedObject]? {
            for r in fetchResults{
                if r.valueForKey("phrase") as String? == selectedAOOasString {
                    selectedAOO = r
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTaskDescription"{
            let DVC = segue.destinationViewController as TaskDescriptionTableViewController
            DVC.MyManagedObjectContext = self.MyManagedObjectContext
            DVC.passedTaskAsString = taskToPass
        }
    }
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let Cell = tableView.cellForRowAtIndexPath(indexPath)
        taskToPass = Cell?.textLabel?.text
        performSegueWithIdentifier("showTaskDescription", sender: self)
        
    }
    
    
    
    
}