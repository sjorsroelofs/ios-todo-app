//
//  NewItemViewController.swift
//  todo-app
//
//  Created by Sjors Roelofs on 19/08/15.
//  Copyright © 2015 Sjors Roelofs. All rights reserved.
//

import UIKit
import CoreData

class NewItemViewController: UIViewController {
    // MARK: IBOutlets
    @IBOutlet weak var titleLabel: UITextField!

    
    // MARK: Properties
    let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
    var managedObjectContext: NSManagedObjectContext? {
        if appDelegate != nil {
            return appDelegate!.managedObjectContext
        }
        
        return nil
    }
    
    
    // MARK: Class method overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: IBActions
    @IBAction func saveItem() {
        if managedObjectContext != nil {
            if let title = titleLabel.text {
                if !title.isEmpty {
                    let entity = NSEntityDescription.entityForName("ToDoItem", inManagedObjectContext: managedObjectContext!)
                    let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext!)
                    
                    item.setValue(title, forKey: "todoTitle")
                    item.setValue(NSDate(), forKey: "todoCreatedAt")
                    item.setValue(false, forKey: "todoCompleted")
                    item.setValue(0, forKey: "todoOrder")
                    
                    do {
                        try managedObjectContext!.save()
                        navigationController?.popToRootViewControllerAnimated(true)
                    } catch {
                        print("Error saving new item")
                    }
                }
            }
        }
    }
}
