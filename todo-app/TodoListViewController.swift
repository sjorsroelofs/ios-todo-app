//
//  TodoListViewController.swift
//  todo-app
//
//  Created by Sjors Roelofs on 19/08/15.
//  Copyright © 2015 Sjors Roelofs. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: IBOutlets
    @IBOutlet weak var itemList: UITableView!
    
    
    // MARK: Properties
    let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
    var managedObjectContext: NSManagedObjectContext? {
        if appDelegate != nil {
            return appDelegate!.managedObjectContext
        }
        
        return nil
    }
    var notificationCenter = NSNotificationCenter.defaultCenter()
    var uncheckedItems = [NSManagedObject]()
    var items = [[NSManagedObject]]()

    
    // MARK: Class method overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchToDoItems()
        
        notificationCenter.addObserver(self, selector: "reloadData:", name: NSManagedObjectContextObjectsDidChangeNotification, object: managedObjectContext)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "todoItemDetailView" {
            if let detailViewController = segue.destinationViewController as? ItemDetailViewController {
                detailViewController.item = sender as? NSManagedObject
            }
        }
    }
    
    
    // MARK: IBAction's
    @IBAction func newItemPressed(sender: UIButton) {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            sender.transform = CGAffineTransformMakeRotation((180.0 * CGFloat(M_PI)) / 180.0)
            }) { (Bool) -> Void in
                sender.transform = CGAffineTransformMakeRotation(0.0)
                self.performSegueWithIdentifier("todoItemNew", sender: nil)
        }
    }
    
    @IBAction func editButtonPressed(sender: UIBarButtonItem) {
        switch itemList.editing {
            case true: sender.title = "Edit"
            default: sender.title = "Done"
        }
        
        itemList.setEditing(!itemList.editing, animated: true)
    }
    
    
    // MARK: UITableViewDataSource methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = itemList.dequeueReusableCellWithIdentifier("ToDoItemCell")! as! TodoItemTableViewCell
        
        cell.item = items[indexPath.section][indexPath.row]
        cell.itemTitle.text = items[indexPath.section][indexPath.row].valueForKey("todoTitle") as? String
        cell.setButtonImage(items[indexPath.section][indexPath.row].valueForKey("todoCompleted") as? Bool)
        cell.itemTitle.textColor = UIColor(white: 0.0, alpha: 1.0)
        
        if items[indexPath.section][indexPath.row].valueForKey("todoCompleted") as? Bool == true {
            cell.itemTitle.textColor = UIColor(white: 0.6, alpha: 1.0)
        }
        
        if indexPath.section == 0 {
            cell.showsReorderControl = true
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let itemToMove = items[sourceIndexPath.section].removeAtIndex(sourceIndexPath.row)
        items[destinationIndexPath.section].insert(itemToMove, atIndex: destinationIndexPath.row)
        
        updateSortOrder()
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let item = items[indexPath.section][indexPath.row] as NSManagedObject? {
                managedObjectContext?.deleteObject(item)
            }
        }
    }
    
    func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            return sourceIndexPath
        }
        
        return proposedDestinationIndexPath
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = itemList.dequeueReusableCellWithIdentifier("ToDoSectionCell")! as! TodoSectionTitleTableViewCell
     
        if section == 1 && items[section].count > 0 {
            cell.sectionTitleLabel.text = "completed"
            return cell.contentView
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || items[section].count == 0 {
            return 0.0
        }
        
        return 40.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("todoItemDetailView", sender: items[indexPath.section][indexPath.row])
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        switch indexPath.section {
            case 0 : return true
            default: return false
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        switch itemList.editing {
            case true: return .None
            default: return .Delete
        }
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    
    // MARK: Custom methods
    func updateSortOrder() {
        for (index, item) in items[0].enumerate() {
            item.setValue(index + 1, forKey: "todoOrder")
            
            do {
                try managedObjectContext!.save()
            } catch {
                print("Error updating sort order")
            }
        }
    }
    
    func reloadData(notification: NSNotification) {
        fetchToDoItems()
        itemList.reloadData()
    }
    
    func fetchToDoItems() {
        items = [[NSManagedObject]]()
        
        if managedObjectContext != nil {
            do {
                let sortOrder = NSSortDescriptor(key: "todoOrder", ascending: true)
                let completedDate = NSSortDescriptor(key: "todoCompletedDate", ascending: false)
                let sortDate = NSSortDescriptor(key: "todoCreatedAt", ascending: false)
                let fetchRequest = NSFetchRequest(entityName: "ToDoItem")
                
                let sortDescriptors = [sortOrder, completedDate, sortDate]
                fetchRequest.sortDescriptors = sortDescriptors
                
                fetchRequest.predicate = NSPredicate(format: "todoCompleted == %@", false)
                
                if let fetchedResults = try managedObjectContext!.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
                    items.append(fetchedResults)
                }
                
                fetchRequest.predicate = NSPredicate(format: "todoCompleted == %@", true)
                
                if let fetchedResults = try managedObjectContext!.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
                    items.append(fetchedResults)
                }
            } catch {
                print("Error fetching results")
            }
        }
    }
}
