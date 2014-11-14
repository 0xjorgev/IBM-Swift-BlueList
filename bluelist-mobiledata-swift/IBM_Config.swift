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
//  IBMConstants.swift
//  bluelist-mobiledata-swift
//
//  Created by Jorge Mendoza on 11/12/14.
//  Copyright (c) 2014 todd. All rights reserved.
//

import Foundation
/**
*  IBM_Config NSObject Class shared between the app and the today's widget Extention, it initializes the
*  Bluemix services
*/
class IBM_Config: NSObject {

    var applicationId = ""
    var applicationSecret = ""
    var applicationRoute  = ""
    var hasValidConfiguration = true
    var errorMessage = ""
    
    /**
    initIBM
    
    Void Method that initializes all the services involed in the BlueList App
    */
    func initIBM(){
        
        // Read the applicationId from the bluelist.plist.
        var configurationPath = NSBundle.mainBundle().pathForResource("bluelist", ofType: "plist")

        
        if(configurationPath != nil){
            var configuration = NSDictionary(contentsOfFile: configurationPath!)
            
            applicationId = configuration!["applicationId"] as String
            print("applicationId " + applicationId)
            
            if(applicationId == ""){
                hasValidConfiguration = false
                errorMessage = "Open the bluelist.plist and set the applicationId to the BlueMix applicationId"
            }
            applicationSecret = configuration!["applicationSecret"] as String
            if(applicationSecret == ""){
                hasValidConfiguration = false
                errorMessage = "Open the bluelist.plist and set the applicationSecret with your BlueMix application's secret"
            }
            applicationRoute = configuration!["applicationRoute"] as String
            if(applicationRoute == ""){
                hasValidConfiguration = false
                errorMessage = "Open the bluelist.plist and set the applicationRoute to the BlueMix application's route"
            }
        }
        
        if(hasValidConfiguration){
        
            IBMBluemix.initializeWithApplicationId(applicationId, andApplicationSecret: applicationSecret, andApplicationRoute: applicationRoute)
            IBMData.initializeService()
            IBMPush.initializeService()
            IBMCloudCode.initializeService()
            IBM_Item.registerSpecialization()
        }
    }
}
