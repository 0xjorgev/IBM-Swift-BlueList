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
//
//  AppDelegate.swift
//  BlueListDataSwift
//
//  Created by todd on 8/8/14.
//  Copyright (c) 2014 todd. All rights reserved.
//

import UIKit
import CoreData


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    var window: UIWindow?

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        
        // Override point for customization after application launch.
        
        var applicationId = ""
        var applicationSecret = ""
        var applicationRoute  = ""
        
        var hasValidConfiguration = true
        var errorMessage = ""
        
        
        let IBMConfig:IBM_Config = IBM_Config()
        IBMConfig.initIBM()
        
        if(IBMConfig.hasValidConfiguration){
            
            var systemVersion:Float = NSString(string: UIDevice.currentDevice().systemVersion).floatValue
            var iOSVersion:Float = 8.1
            
            if  systemVersion >= iOSVersion {
                
                let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert|UIUserNotificationType.Badge|UIUserNotificationType.Sound, categories: nil)
                application.registerUserNotificationSettings(settings)
                application.registerForRemoteNotifications()
                
            } else {
                
                application.registerForRemoteNotificationTypes(UIRemoteNotificationType.Alert|UIRemoteNotificationType.Badge|UIRemoteNotificationType.Sound)
            }
        
        }else{
            NSException().raise()
        }
        return true
    }
    
    
 
    /**
    didRegisterForRemoteNotificationsWithDeviceToken
    This method allows the application to be able to recive remote push notifications
    
    :param: application UIApplication Object
    :param: deviceToken PushNotification device token
    */
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        var pushService:IBMPush = IBMPush(version: "8.1")
        var bfTask:BFTask = pushService.registerDevice("ab1231c2-0c66-47a3-b6f9-d0cd4c15023a", withConsumerId: UIDevice.currentDevice().name, withDeviceToken: deviceToken.description)
        
        if (bfTask.error() != nil) {
            
            NSLog("Registration Error:%@", bfTask.error().description)
        }
    }
    
    /**
    didReceiveRemoteNotification
    This method handles the remote notifications and shows an UIAlertController with the notification
    
    :param: application UIApplication Object
    :param: userInfo    AnyObject Object
    */
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {

        //The userInfo is empty!
        var alert = UIAlertController(title: "BlueList Notification", message: "The BlueList has been updated." , preferredStyle: UIAlertControllerStyle.Alert)
        var okAction:UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(okAction)
        self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        
    }
}

