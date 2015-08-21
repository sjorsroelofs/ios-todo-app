//
//  TodoItemTableViewCell.swift
//  todo-app
//
//  Created by Sjors Roelofs on 20/08/15.
//  Copyright © 2015 Sjors Roelofs. All rights reserved.
//

import UIKit
import CoreData

class TodoItemTableViewCell: UITableViewCell {

    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    var item: NSManagedObject?
    let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
    var managedObjectContext: NSManagedObjectContext? {
        if appDelegate != nil {
            return appDelegate!.managedObjectContext
        }
        
        return nil
    }

    @IBAction func donePressed() {
        if item != nil {
            var setCompleted = true;
            
            if item?.valueForKey("todoCompleted") as? Bool == true {
                setCompleted = false;
            }
            
            if managedObjectContext != nil {
                item?.setValue(setCompleted, forKey: "todoCompleted")
                
                if setCompleted == true {
                    item?.setValue(NSDate(), forKey: "todoCompletedDate")
                    item?.setValue(nil, forKey: "todoOrder")
                } else {
                    item?.setValue(nil, forKey: "todoCompletedDate")
                }
                
                do {
                    try managedObjectContext!.save()
                    setButtonImage(setCompleted);
                } catch {
                    print("Error marking item as completed")
                }
            }
        }
    }
    
    func setButtonImage(completed: Bool?) {
        var isCompleted = false
        
        if completed != nil {
            isCompleted = completed!
        }
        
        if isCompleted {
            doneButton.setImage(UIImage(named: "checkbox-done"), forState: .Normal)
        } else {
            doneButton.setImage(UIImage(named: "checkbox-undone"), forState: .Normal)
        }
    }
}
