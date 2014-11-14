//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//
//  IBM_ListViewController.swift
//  bluelist-mobiledata-swift
//
//  Created by todd on 8/11/14.
//  Copyright (c) 2014 todd. All rights reserved.
//

import Foundation
import UIKit

class IBM_ListViewController : UITableViewController {
    
    @IBOutlet weak var addButton: UIBarButtonItem!

    var itemList:[IBM_Item] = []
    var cloudCode:IBMCloudCode!
    
    // If edit was triggered, the cell being edited != nil.
    var editedCell : UITableViewCell?
    
    //MARK: - View initialization and refreshing
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        // Setting up the refresh control
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Loading Items")
        
        self.refreshControl!.addTarget(self, action: Selector("handleRefreshAction") , forControlEvents: UIControlEvents.ValueChanged)
    
        // Load initial set of items
        self.refreshControl!.beginRefreshing()
        self.listItems({self.refreshControl!.endRefreshing() })
        
        self.cloudCode = IBMCloudCode.service()

    }
    
    override func viewWillAppear(animated:Bool)
    {
        super.viewWillAppear(animated)
        self.listItems({})
    }
    
    func handleRefreshAction()
    {
        self.listItems({

            self.refreshControl!.endRefreshing()
            
        })
    }
    
    func endRefreshing(){
        
        self.refreshControl!.endRefreshing()
    }
    
    func reloadLocalTableData()
    {
        //Clousure to sort the list elements based on the priority value
        self.itemList = sorted(itemList, {
            return $0.priority > $1.priority
        })
        
        // TODO:  Need to implement this
        //[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO]
        self.tableView.reloadData()
    }
    

    override func setEditing (editing: Bool, animated: Bool)
    {
        super.setEditing(editing, animated:animated)
        self.tableView.setEditing(editing, animated:true)
    
        // Disable add button in edit mode
        if (editing) {
            self.addButton.enabled = false
        } else {
            self.addButton.enabled = true
        }
    }
    
    //MARK: - CRUD Operations
    
    func listItems(callback:() -> Void)
    {
        
        var qry = IBMQuery(forClass: "Item")
        qry.find().continueWithBlock{ task in
            if((task.error()) != nil) {
                    println("listItems failed with error: %@", task.error)
            } else {
                self.itemList = []
                if let result = task.result() as? NSArray {
                    for i in 0..<result.count {
                        self.itemList.append(result[i] as IBM_Item)
                    }
                }
                
                self.reloadLocalTableData()
                callback()
            }
            return nil
        }
    }
  
    func createItem(item : IBM_Item)
    {
        self.itemList.append(item)
        self.reloadLocalTableData()
        
        item.save().continueWithBlock{ task in
            if((task.error()) != nil) {
                println("createItem failed with error: %@", task.error)
            }
            self.broadcastUpdateNotification()
            return nil
        }
    }
    
    
    
    func updateItem(item : IBM_Item)
    {
        self.editedCell!.textLabel.text = item.name
        
        item.save().continueWithBlock{ task in
            if(task.error() != nil) {
                println("updateItem failed with error: %@", task.error)
            }
            self.broadcastUpdateNotification()
            return nil
        }
    }
    
    func deleteItem(item : IBM_Item)
    {
        for i in 0..<itemList.count {
            if item.name == itemList[i].name {
                itemList.removeAtIndex(i)
                break
            }
        }
        self.reloadLocalTableData()
        
        item.delete().continueWithBlock{ task in
            if(task.error() != nil){
                println("deleteItem failed with error: %@", task.error)
            } else {
                self.listItems({})
            }
            self.broadcastUpdateNotification()
            return nil
        }
        // Exit edit mode to avoid need to click Done button
        self.setEditing(false, animated: true)
    }
    
    //MARK: - Table controls
        
    override func numberOfSectionsInTableView (tableView : UITableView) -> NSInteger
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemList.count
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView (tableView : UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,  forRowAtIndexPath indexPath: NSIndexPath){
        if(editingStyle == UITableViewCellEditingStyle.Delete){
            // Perform delete
            self.deleteItem(self.itemList[indexPath.row])
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:
        NSIndexPath) -> UITableViewCell {
            let CellIndentifier: String = "ListItemCell"
            var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(CellIndentifier) as UITableViewCell
            cell.textLabel.text = self.itemList[indexPath.row].name
            self.setTableViewCellImage(self.itemList[indexPath.row], tablevViewCell: cell)
            return cell
    }
    
    func setTableViewCellImage(item:IBM_Item, tablevViewCell:UITableViewCell){
        
        switch item.priority {
        case 0:
            tablevViewCell.imageView.image = UIImage(named: "!.png")
        case 1:
            tablevViewCell.imageView.image = UIImage(named: "!!.png")
        case 2:
            tablevViewCell.imageView.image = UIImage(named: "!!!.png")
        default:
            NSLog("Default case for image assignation")        }
    }
    
    //MARK: - Navigation to/from Create/Edit View

    @IBAction func updateListWithSegue (segue : UIStoryboardSegue )
    {
        var createEditController : IBM_CreateEditItemViewController = segue.sourceViewController as IBM_CreateEditItemViewController
        if(createEditController.item?.objectForKey("name") != nil){
            if self.editedCell != nil {
                // Is Update
                self.updateItem(createEditController.item!)
            }else{
                // Is Add
                self.createItem(createEditController.item!)
            }
        }
        self.editedCell = UITableViewCell()
    }
    
    override func prepareForSegue(segue : UIStoryboardSegue,  sender : AnyObject!)
    {
        var navigationController = segue.destinationViewController as UINavigationController
        var createEditController = navigationController.viewControllers.last as  IBM_CreateEditItemViewController 
        if(sender as NSObject == self.addButton){
            createEditController.item = IBM_Item()
        }else{
            // is edit so seed the item with the title
            self.editedCell = sender as? UITableViewCell
            var indexPath = self.tableView!.indexPathForCell(self.editedCell!)
            createEditController.item = self.itemList[indexPath!.row]
        }
    }
    
    /**
    broadcastUpdateNotification
    Void Method it creates a POST request to the IBMCLOUDCODE service in the Bluemix App container
    */
    func broadcastUpdateNotification(){
        
        var task: BFTask = self.cloudCode.post("notifyOtherDevices/", withJsonPayload: nil, withHeaders: nil).continueWithBlock{ task in
            if(task.error() != nil){
                println("Post Notification Error: %@", task.error)
            }
            return nil
        }
    }
}