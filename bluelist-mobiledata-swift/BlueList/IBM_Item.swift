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
//  IBM_Item.swift
//  bluelist-mobiledata-swift
//
//  Created by Erin Bartholomew on 8/19/14.
//  Copyright (c) 2014 todd. All rights reserved.
//

import UIKit

class IBM_Item: IBMDataObject,IBMDataObjectSpecialization {
   
    let nameKey = "name"
    let priorityKey = "priority"
    
    var name: String {
        get {
            if let nameStr = super.objectForKey(nameKey) as? String {
                return nameStr
            } else {
                return ""
            }
        }
        set {
            super.setObject(newValue, forKey: nameKey)
        }
        
    }
    
    //Priority value with a range from 0 to 2 [0,2] used to sort the IBM_Item list
    var priority: Int {
     
        get {
            if let priorityInt = super.objectForKey(priorityKey) as? Int {
                return priorityInt
            } else {
                return 0
            }
        }
        set {
            super.setObject(newValue, forKey: priorityKey)
        }
    }
    
    required override init() {
        super.init()
    }
    
    override init(`class` classname: String!) {
        super.init(`class`:classname)
    }
    
    class func dataClassName() -> String! {
        return "Item"
    }
}
