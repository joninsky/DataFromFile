//
//  TaskDescriptionTableViewController.swift
//  DatafromFile
//
//  Created by Jon Vogel on 12/18/14.
//  Copyright (c) 2014 Jon Vogel. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TaskDescriptionTableViewController: UIViewController {
    
    var MyManagedObjectContext: NSManagedObjectContext?
    var passedTaskAsString: String?
    var arrayOfTaskDescriptions: [NSManagedObject]?
    var passedTask: NSManagedObject?
    
    @IBOutlet weak var txtObjective: UITextView!
    @IBOutlet weak var txtPhrase: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTask()
        getDescriptions()
        loadDescriptions()
        self.navigationItem.title = passedTask!.valueForKey("phrase") as String?
    }
    
    func getDescriptions(){
        let fetchRequest = NSFetchRequest(entityName: "TaskDescription")
        let p = NSPredicate(format: "tasks.phrase == %@", passedTask!.valueForKey("phrase") as String!)
        fetchRequest.predicate = p
        let sort = NSSortDescriptor(key: "phrase", ascending: true, selector: "localizedStandardCompare:")
        fetchRequest.sortDescriptors = [sort]
        if let fetchedResults = MyManagedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as [NSManagedObject]? {
            arrayOfTaskDescriptions = fetchedResults
        }
    }
    
    
    func getSubtasks(taskDescription: NSManagedObject) -> [NSManagedObject]?{
        let fetchRequest = NSFetchRequest(entityName: "SubTaskDescription")
        let p = NSPredicate(format: "taskdescription.phrase == %@" , taskDescription.valueForKey("phrase") as String!)
        fetchRequest.predicate = p
        let sort = NSSortDescriptor(key: "phrase", ascending: true, selector: "localizedStandardCompare:")
        fetchRequest.sortDescriptors = [sort]
        if let fetchResults = MyManagedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as [NSManagedObject]? {
            return fetchResults
        }else {
            return nil
        }
    }
    
    
    func fetchTask(){
        let fetchRequest = NSFetchRequest(entityName: "Tasks")
        let p = NSPredicate(format: "phrase == %@", passedTaskAsString!)
        if let fetchedResults = MyManagedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as [NSManagedObject]?{
            for r in fetchedResults{
                if r.valueForKey("phrase") as String? == passedTaskAsString{
                    txtObjective.text = r.valueForKey("objective") as String?
                    passedTask = r
                }
            }
        }
    }
    
    func loadDescriptions() {
        for t in arrayOfTaskDescriptions!{
            var d = t.valueForKey("phrase") as String?
            txtPhrase.text = txtPhrase.text + d! + "\n" + "\n"
            if t.valueForKey("subTaskDescription") != nil {
                var subTasks = getSubtasks(t)
                for var i = 0; i < subTasks!.count; ++i{
                    txtPhrase.contentInset = UIEdgeInsetsMake(0, 30, 0, 0)
                    var p = subTasks![i].valueForKey("phrase") as String?
                    txtPhrase.text = txtPhrase.text + p! + "\n"
                    if i+1 == subTasks!.count{
                        txtPhrase.text = txtPhrase.text + "\n"
                    }
                   // txtPhrase.attributedText = "Go"
                }
            }
        }
    }
}