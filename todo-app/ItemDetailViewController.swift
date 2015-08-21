//
//  ItemDetailViewController.swift
//  todo-app
//
//  Created by Sjors Roelofs on 20/08/15.
//  Copyright © 2015 Sjors Roelofs. All rights reserved.
//

import UIKit
import CoreData

class ItemDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var completedDateLabel: UILabel!
    
    var item: NSManagedObject?;
    let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
    var managedObjectContext: NSManagedObjectContext? {
        if appDelegate != nil {
            return appDelegate!.managedObjectContext
        }
        
        return nil
    }
    let dateFormatter = NSDateFormatter();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if item != nil {
            titleLabel.text = item!.valueForKey("todoTitle") as? String
            
            dateFormatter.dateFormat = "dd-MM-YYYY 'at' HH:mm"
            let dateString = dateFormatter.stringFromDate((item!.valueForKey("todoCreatedAt") as? NSDate)!)
            
            dateLabel.text = "Added on \(dateString)"
            
            if item!.valueForKey("todoCompleted") as? Bool == true {
                if let date = item!.valueForKey("todoCompletedDate") as? NSDate {
                    completedDateLabel.text = "Completed on \(dateFormatter.stringFromDate(date))"
                    completedDateLabel.hidden = false
                }
            } else {
                completedDateLabel.hidden = true
            }
        }
    }

    @IBAction func deleteItem() {
        if item != nil {
            managedObjectContext?.deleteObject(item!)
        }
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
}
