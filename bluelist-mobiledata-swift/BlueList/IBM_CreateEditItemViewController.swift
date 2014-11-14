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
//  IBM_CreateEditItemViewController.swift
//  bluelist-mobiledata-swift
//
//  Created by todd on 8/12/14.
//  Copyright (c) 2014 todd. All rights reserved.
//

import Foundation
import UIKit

class IBM_CreateEditItemViewController : UIViewController, UITextFieldDelegate {

    @IBOutlet weak var itemTextField: UITextField!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var prioritySLider: UISlider!
    var sliderPriorityValue:Int = 0

    var item: IBM_Item?
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        if let itemName = item?.name {
            self.itemTextField.text = itemName
        }
        
        if let itemPriority = item?.priority {
            self.prioritySLider.value = Float(itemPriority)
        }
        
        self.itemTextField.becomeFirstResponder()
        self.itemTextField.delegate = self

    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if(sender as? NSObject !=  self.cancelButton && !self.itemTextField.text.isEmpty){
            self.item?.name = self.itemTextField.text
            self.item?.priority = self.sliderPriorityValue
            
            
        } else {
            //self.item.delete()
            self.item = nil
        }
    }

    func textFieldShouldReturn( textField : UITextField) -> Bool{
        if (!self.itemTextField.text.isEmpty){
            self.performSegueWithIdentifier("DoneButtonSegue", sender: self as AnyObject);
            return true
        }
        else{
            return false
        }
        
    }

    func textField(textField: UITextField!, shouldChangeCharactersInRange range: NSRange, replacementString string: String!) -> Bool {
        if(!self.itemTextField.text.isEmpty && !string.isEmpty){
            self.saveButton.enabled = true
        }
        return true;
    }
    
    @IBAction func sliderValueChanged(sender:UISlider){
        
        self.sliderPriorityValue = Int(sender.value)
        self.saveButton.enabled = true
        
    }

}
