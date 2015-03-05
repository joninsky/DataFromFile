//
//  AOOData.swift
//  DatafromFile
//
//  Created by Jon Vogel on 12/14/14.
//  Copyright (c) 2014 Jon Vogel. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class AOOData: UITableViewController {
    
    
    
    
    var MyManagedObjectContext: NSManagedObjectContext?
    
    var arrayOfAOO: [NSManagedObject]?
    
    var aooToPass: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
    }
    
    
    func loadData() {
        let fetchRequest = NSFetchRequest(entityName: "AOOs")
        let sort = NSSortDescriptor(key: "phrase", ascending: true, selector: "localizedStandardCompare")
        
        if let fetchResults = MyManagedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as [NSManagedObject]?{
            arrayOfAOO = fetchResults
        }
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayOfAOO != nil {
            return arrayOfAOO!.count
        }else{
            return 1
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var Cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
        if arrayOfAOO != nil {
            var theCurrentAOO = arrayOfAOO![indexPath.row]
            Cell.textLabel?.text = theCurrentAOO.valueForKey("phrase") as String?
        }
        
        return Cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTasks"{
            let DVC = segue.destinationViewController as TasksTableViewController
            DVC.MyManagedObjectContext = self.MyManagedObjectContext
            DVC.selectedAOOasString = aooToPass
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let Cell = tableView.cellForRowAtIndexPath(indexPath)
        aooToPass = Cell!.textLabel!.text
        performSegueWithIdentifier("showTasks", sender: self)
    }
    
    
    
    
    
    
}