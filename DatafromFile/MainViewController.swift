//
//  ViewController.swift
//  DatafromFile
//
//  Created by Jon Vogel on 12/14/14.
//  Copyright (c) 2014 Jon Vogel. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class MainViewController: UIViewController {

    lazy var MyManagedObjectContext: NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let MyManagedObjectContext = appDelegate.managedObjectContext {
            return MyManagedObjectContext
        }else{
           return nil
        }
    }()
    
    @IBOutlet weak var txtViewAll: UITextView!
    
    
    
    var everything: [AnyObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get the file path for the txt file that we will read all the PPL PTS from
        let URL: String = NSBundle.mainBundle().pathForResource("PPLPTS", ofType: "txt")!
      let urlasNSURL = NSURL(fileURLWithPath: URL)
         let data = NSData(contentsOfURL: urlasNSURL!)
     let largestring = NSString(data: data!, encoding: NSUTF8StringEncoding) as String
      
      
      everything = largestring.componentsSeparatedByString("\n")

      
      
        //everything = NSString(contentsOfFile: URL, encoding: NSUTF8StringEncoding, error: nil).componentsSeparatedByString("\n")
        
        txtViewAll.text = ""
        for s in everything! as [String]{
            txtViewAll.text = txtViewAll.text + s + "\n"
        }
        
        getStuffFromFile()
    }
    
    
    
    func getStuffFromFile() {
        let fetchRequest = NSFetchRequest(entityName: "AOOs")
        let fetchResults = MyManagedObjectContext?.countForFetchRequest(fetchRequest, error: nil)
        if fetchResults == 0{
            var currentAOO: String = ""
            var currentTask: String = ""
            var currentTaskDescription: String = ""
            for var i = 0; i < everything!.count; ++i {
                switch everything![i] as String {
                    case "":
                        if everything![i+2] as String == "note"{
                            addAOO(everything![i+1] as String, noteToAdd: everything![i+3] as String)
                            currentAOO = everything![i+1] as String
                        }else{
                            addAOO(everything![i+1] as String, noteToAdd: "")
                            currentAOO = everything![i+1] as String
                        }
                    case "task":
                        if everything![i+2] as String == "note"{
                            if everything![i+5] as String == "ses"{
                                addTask(everything![i+1] as String, noteToAdd: everything![i+3] as String, objectiveToAdd: everything![i+4] as String, isSES: true, aooToRelate: currentAOO)
                                currentTask = everything![i+1] as String
                            }else{
                                addTask(everything![i+1] as String, noteToAdd: everything![i+3] as String, objectiveToAdd: everything![i+4] as String, isSES: false, aooToRelate: currentAOO)
                                currentTask = everything![i+1] as String
                            }
                        }else{
                            if everything![i+3] as String == "ses"{
                                addTask(everything![i+1] as String, noteToAdd: "", objectiveToAdd: everything![i+2] as String, isSES: true, aooToRelate: currentAOO)
                                currentTask = everything![i+1] as String
                            }else{
                                addTask(everything![i+1] as String, noteToAdd: "", objectiveToAdd: everything![i+2] as String, isSES: false, aooToRelate: currentAOO)
                                currentTask = everything![i+1] as String
                            }
                        }
                    case "disc":
                        while everything![i] as String != "enddisc" {
                            if everything![i] as String != "disc"{
                                if everything![i] as String == "subdisc"{
                                    while everything![i] as String != "disc"{
                                        if everything![i] as String != "subdisc"{
                                            addSubTaskDescription(everything![i] as String, descripitonToRelate: currentTaskDescription)
                                            ++i
                                        }else{
                                            ++i
                                        }
                                    }
                                }
                                if everything![i] as String != "disc"{
                                    addTaskDescription(everything![i] as String, taskToRelate: currentTask)
                                    currentTaskDescription = everything![i] as String
                                    ++i
                                }else{
                                    ++i
                                }
                                
                            }else{
                                ++i
                            }
                        }
                    default:
                        continue
                }
            }
        }
        
        
        
    }
    
    
    func addAOO ( aooToAdd: String, noteToAdd: String) {
        var newAOO = NSEntityDescription.insertNewObjectForEntityForName("AOOs", inManagedObjectContext: MyManagedObjectContext!) as NSManagedObject
        newAOO.setValue(aooToAdd, forKeyPath: "phrase")
        newAOO.setValue(noteToAdd, forKeyPath: "note")
        newAOO.setValue(false, forKeyPath: "isComplete")
        MyManagedObjectContext!.save(nil)
    }
    
    
    func addTask ( taskToAdd: String, noteToAdd: String, objectiveToAdd: String, isSES: Bool, aooToRelate: String){
        //Set everything exeptp the AOO Relationship
        var newTask = NSEntityDescription.insertNewObjectForEntityForName("Tasks", inManagedObjectContext: MyManagedObjectContext!) as NSManagedObject
        newTask.setValue(taskToAdd, forKeyPath: "phrase")
      if taskToAdd == "Task A: After Landing, Parking, and Securing (ASEL and ASES)"{
         println(taskToAdd)
      }
      
      
        newTask.setValue(noteToAdd, forKeyPath: "note")
        newTask.setValue(objectiveToAdd, forKeyPath: "objective")
        if isSES == true {
            newTask.setValue(true, forKeyPath: "isSES")
        }else{
            newTask.setValue(false, forKeyPath: "isSES")
        }
        newTask.setValue(false, forKeyPath: "isComplete")
        
        
        //Set AOO Relationship
        var fetchrequest = NSFetchRequest(entityName: "AOOs")
        //println(aooToRelate)
        var p = NSPredicate(format: "phrase == %@", aooToRelate)
        fetchrequest.predicate = p
        if let fetchResults = MyManagedObjectContext!.executeFetchRequest(fetchrequest, error: nil){
            //for f in fetchResults {
              //  println(f.valueForKey("phrase"))
            //}
            var aooThatIGot = fetchResults[0] as NSManagedObject
            newTask.setValue(aooThatIGot, forKeyPath: "aoo")
        }
        MyManagedObjectContext!.save(nil)
    }
    
    
    
    func addTaskDescription(phraseToAdd: String, taskToRelate: String) {
        
        //Set everything but the relationship
        var newDesc = NSEntityDescription.insertNewObjectForEntityForName("TaskDescription", inManagedObjectContext: MyManagedObjectContext!) as NSManagedObject
        newDesc.setValue(phraseToAdd, forKey: "phrase")
        newDesc.setValue(false, forKey: "isClutter")
        //newDesc.setValue("", forKey: "shortPhrase")
        
        //Set the relationship to the Task
        let fetchRequest = NSFetchRequest(entityName: "Tasks")
        let p = NSPredicate(format: "phrase == %@", taskToRelate)
        fetchRequest.predicate = p
        if let fetchResults = MyManagedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as [NSManagedObject]?{
            var taskThatIGot = fetchResults[0]
            newDesc.setValue(taskThatIGot, forKey: "tasks")
        }
        MyManagedObjectContext!.save(nil)
    }
    
    func addSubTaskDescription(phraseToAdd:String, descripitonToRelate: String){
        
        //Set everything for the sub task description except the relationship
        var newSubTaskDescription = NSEntityDescription.insertNewObjectForEntityForName("SubTaskDescription", inManagedObjectContext: MyManagedObjectContext!) as NSManagedObject
        newSubTaskDescription.setValue(phraseToAdd, forKey: "phrase")
        newSubTaskDescription.setValue(false, forKeyPath: "isClutter")
        //newSubTaskDescription.setValue("", forKeyPath: "shortPhrase")
        
        //Set the relaitonsip the the appropriate task description
        let fetchrequest = NSFetchRequest(entityName: "TaskDescription")
        let p = NSPredicate(format: "phrase == %@", descripitonToRelate)
        fetchrequest.predicate = p
        if let fetchResults = MyManagedObjectContext!.executeFetchRequest(fetchrequest, error: nil) as [NSManagedObject]? {
            var taskDescriptionThatIGot = fetchResults[0]
            newSubTaskDescription.setValue(taskDescriptionThatIGot, forKeyPath: "taskdescription")
        }
        MyManagedObjectContext!.save(nil)
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showData" {
            let DVC = segue.destinationViewController  as AOOData
            DVC.MyManagedObjectContext = self.MyManagedObjectContext
        }
    }

    
    @IBAction func goToDataDrill(sender: AnyObject) {
        
        performSegueWithIdentifier("showData", sender: self)
    }


}

