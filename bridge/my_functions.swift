//
//  my_functions.swift
//  swift_bridge
//
//  Created by Michael Tran on 8/10/2015.
//  Copyright © 2015 intcloud. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

// for Bridge
let bridge_theme = "bridge";
var myrecord = (function:"", param:"");
// myrecord = process_scheme((request.URL?.absoluteString)!);

func process_scheme(url: String) -> (String, String) {
    var functionName = "";
    var param = "";
    let urlString = url;
    let theme_length = bridge_theme.characters.count + 1 ; // take into the :
    //delete first 7 chars
    let str = urlString.substringFromIndex(urlString.startIndex.advancedBy(theme_length));
    //look for the ? char
    let needle: Character = "?";
    //if it is not nul  -> found
    if let idx = str.characters.indexOf(needle) {
        //the pos of it from 1
        let pos = str.startIndex.distanceTo(idx);
        //how many char for the param
        let count_back = str.characters.count - pos;
        //take only whatever before the ?
        functionName = str.substringToIndex(str.endIndex.advancedBy(-1 * count_back));
        //take the whole param string
        param=str.substringFromIndex(str.endIndex.advancedBy(-1 * count_back));
        //delete the '?param=' part, it is 7 character length
        param=param.substringFromIndex(param.startIndex.advancedBy(7));
        //remove the uuencode for space
        param = param.stringByReplacingOccurrencesOfString("%20",
            withString: " ",
            options: NSStringCompareOptions.LiteralSearch,
            range: param.startIndex..<param.endIndex)
        
        print("function = " + functionName + "\n" + "param= '" + param + "'");
    }
    else {
        functionName = urlString.substringFromIndex(urlString.startIndex.advancedBy(7));
    }
    
    print("got an ios function call: \(functionName)");
    
    return (functionName, param);
}


// usage : alert("network", message: "alive");

func alert (title: String, message: String) {
    let myalert = UIAlertView();
    myalert.title = title;
    myalert.message = message;
    myalert.addButtonWithTitle("OK");
    myalert.show();

}

// list file in document , return array of string 
// usage: var myarray = Array[]; myarray = listFiles();

func listFiles() -> [String] {
    let dirs = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
    if dirs != nil {
        let dir = dirs![0]
        do {
            let fileList = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(dir)
            return fileList as [String]
        }catch { }
        
    }else{
        let fileList = [""]
        return fileList
    }
    let fileList = [""]
    return fileList
    
}

//check internet 
// usage: if is_network_on() { alert("network", message: "alive"); } else {alert("network", message: "drop dead");}

func is_network_on() -> Bool {
    
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
        SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
    }
    var flags = SCNetworkReachabilityFlags()
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
        return false
    }
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    return (isReachable && !needsConnection)

}

// otherway
// usage: if Reachability.isConnectedToNetwork() {} else {}

public class Reachability {
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}

// MARK: - Local notification
// notification in background or alert in foreground
// usage: pop_message("this is message");
// put this part under appDelegate first to enable notification
/*
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
    UIApplication.sharedApplication().cancelAllLocalNotifications()
    
    return true
}
*/

func pop_message(my_message: String) {
     var window: UIWindow?
    // Show an alert if application is active
    if UIApplication.sharedApplication().applicationState == .Active {
       var alert = UIAlertView(title: nil, message: my_message, delegate: nil, cancelButtonTitle: "OK");   alert.show();
    } else {
        // Otherwise present a local notification
        let notification = UILocalNotification()
        notification.alertBody = my_message;
        notification.soundName = "Default";
        UIApplication.sharedApplication().presentLocalNotificationNow (notification)
    }
    
}

// string class
extension String {

var lastPathComponent: String {

get {
    return (self as NSString).lastPathComponent
}
}
var pathExtension: String {

get {
    
    return (self as NSString).pathExtension
}
}
var stringByDeletingLastPathComponent: String {

get {
    
    return (self as NSString).stringByDeletingLastPathComponent
}
}
var stringByDeletingPathExtension: String {

get {
    
    return (self as NSString).stringByDeletingPathExtension
}
}
var pathComponents: [String] {

get {
    return (self as NSString).pathComponents
}
}

func stringByAppendingPathComponent(path: String) -> String {
    
    let nsSt = self as NSString
    
    return nsSt.stringByAppendingPathComponent(path)
}

func stringByAppendingPathExtension(ext: String) -> String? {
    
    let nsSt = self as NSString
    
    return nsSt.stringByAppendingPathExtension(ext)
}

} // string extention

// MARK: -location services

/*
import CoreLocation
var lat: Double = 0;
var long: Double =  0;

let locationManager = CLLocationManager();

func init_location(me: Any) {
    locationManager.requestWhenInUseAuthorization();
    if CLLocationManager.locationServicesEnabled() {
        locationManager.delegate = me as? CLLocationManagerDelegate ;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestAlwaysAuthorization();
        locationManager.startUpdatingLocation();
    }
    else{
        print("Location service disabled");
    }
}

func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    var userLocation:CLLocation = locations[0] as! CLLocation
    let long = userLocation.coordinate.longitude;
    let lat = userLocation.coordinate.latitude;
    print (lat,  " , ",  long);
    locationManager.stopUpdatingLocation();
}

func update_location () {
    locationManager.startUpdatingLocation();
    print (lat,  " , ",  long);
    locationManager.stopUpdatingLocation();

}
*/

