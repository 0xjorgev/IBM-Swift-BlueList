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
//  TodayViewController.swift
//  BlueList-Todays-widget
//
//  Created by Jorge Mendoza on 11/12/14.
//  Copyright (c) 2014 todd. All rights reserved.
//

import UIKit
import CoreData
import NotificationCenter

/**
*  This Class is the main class of the today's widget extention, it call the same datasource that the main app uses, it only shows
*  the first 4 items sorted by the priority value
*/
class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDataSource, UITableViewDelegate {
    
    //
    //UITableVIew Object
    //
    @IBOutlet weak var todayTableView: UITableView!
    
    //
    //Array of IBM_Item Objects
    //
    var itemList:[IBM_Item] = []
    
    /**
    
    viewDidLoad() 
    Event Method, it calls the IBMConfig Object, set's the widget size in the Today View
    and load the List using the IBMData Method
    
    */
    override func viewDidLoad()
    {
        let IBMConfig:IBM_Config = IBM_Config()
        IBMConfig.initIBM()
        self.todayTableView.frame = CGRectMake(0, 0, self.preferredContentSize.width, self.preferredContentSize.height)
        
        self.listItems({})
        super.viewDidLoad()
        
    }
    
    /**
    didReceiveMemoryWarning() 
    called if a memory warning is triggered
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
    widgetPerformUpdateWithCompletionHandler
    
    :param: completionHandler <#completionHandler description#>
    */
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
    /**
    reloadLocalTableData() 
    it sorts the data based in the priority value of the items and refresh the UITableView Object
    */
    func reloadLocalTableData()
    {
        //Sorting by Priority
        self.itemList = sorted(itemList, {

            return $0.priority > $1.priority
        })
        self.todayTableView.reloadData()
    }
    
    
    //MARK: - CRUD Operations
    /**
    listItems
    This function calls the IBMQuery Object to obtain the list of items stored in the mobileData service of
    the bluemix app
    
    :param: callback void callback
    */
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
                        
                        var tmpIBMItem = result[i] as IBMDataObject
                        var item:IBM_Item = IBM_Item()
                        
                        if let name = tmpIBMItem.objectForKey("name") as? String {
                            item.name = name
                        }
                        
                        if let priority = tmpIBMItem.objectForKey("priority") as? Int {
                            item.priority = priority
                        } else {
                            item.priority = 0
                        }
                        
                        self.itemList.append(item)
                    }
                }
                
                self.reloadLocalTableData()
                callback()
            }
            return nil
        }
    }
    
    //MARK: - Table controls
    
    /**
    numberOfSectionsInTableView
    UITableViewDelegate Method, it sets the number of sections to show in the UITableView
    
    :param: tableView UITableView Element
    
    :returns: the number of sections visible in the UITableView
    */
    func numberOfSectionsInTableView (tableView : UITableView) -> NSInteger
    {
        return 1
    }
    
    /**
    numberOfRowsInSection
    UITableView Delegate Method
    
    :param: tableView UITableView Element
    :param: section   IndexPath section
    
    :returns: <#return value description#>
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //This modifies the size of the widget
        var size:CGSize = self.preferredContentSize
        var rowSize:CGFloat = 44
        size.height = (CGFloat(4) * rowSize)
        self.preferredContentSize = size
        
        if self.itemList.count >= 4 {
            //Fixed value to show only the first 4 objects
            return 4
            
        } else {
            
            return self.itemList.count
        }
    }
    
    /**
    cellForRowAtIndexPath
    UITableView Delegate Method called to render and setup each cell in the UITableView Element
    
    :param: tableView UITableView Element
    :param: indexPath NSIndexPath stores the row and section for each UITableViewCell in the UITableView
    
    :returns: UITableViewCell customized
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:
        NSIndexPath) -> UITableViewCell {
            let CellIndentifier: String = "ListItemCell"
            var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(CellIndentifier) as UITableViewCell
            cell.textLabel.text = self.itemList[indexPath.row].name
            self.setTableViewCellImage(self.itemList[indexPath.row], tablevViewCell: cell)
            return cell
    }
    
    
    /**
    setTableViewCellImage
    Method that sets the UITableViewCell ImageView based on the priority value of the IBM_Item object
    
    :param: item           IBM_Item used to get the data to be showed in the UITableViewCell
    :param: tablevViewCell UITableViewCell to be customized
    */
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
    
    
    /**
    didSelectRowAtIndexPath
    Method that handles the tap event in each cell of the UITableView Element
    
    :param: tableView UITableView Element
    :param: indexPath NSIndexPath stores the row and section for each UITableViewCell in the UITableView
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
