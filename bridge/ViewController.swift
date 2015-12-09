//
//  ViewController.swift
//  swift_bridge
//
//  Created by Michael Tran on 8/10/2015.
//  Copyright © 2015 intcloud. All rights reserved.
//

import UIKit
import CoreLocation

var lat: Double = 0;
var long: Double =  0;


class ViewController: UIViewController, UIWebViewDelegate , CLLocationManagerDelegate {
    
@IBOutlet weak var webView: UIWebView!
    
let locationManager = CLLocationManager();
    
   
    // this is the main function to trap JS call via document.location
    // either by click or js function call
    
    func webView(webView: UIWebView,
        shouldStartLoadWithRequest request: NSURLRequest,
        navigationType nType: UIWebViewNavigationType) -> Bool {
            
   
        //the scheme is the first part of the document.location before th ':'
        //in JS can be anything predefined ie aaa bbb, in this case we use 'bridge:'
        
            if request.URL?.scheme == bridge_theme
            {
                myrecord = process_scheme((request.URL?.absoluteString)!);
                
               switch myrecord.function {
                case "ios_alert":alert("Bridging" , message: myrecord.param);
                case "ios_popup": pop_new_page(myrecord.param);
                case "ios_pop_message": pop_message(myrecord.param);
                case "exchange" : do_exchange(myrecord.param);
                case "ios_geo":send_geolocation();
                default : print("Not defined: \(myrecord.function)")
                }
                
                // we do not want to actually leave the page when this is triggered
                return false
            }
            
            // make sure real requests are requested
            return true
    }
    
    // Callback when the webpage is finished loading
    func webViewDidFinishLoad(web: UIWebView){
       
        // looking for the current URL
        let currentURL = web.request?.URL?.absoluteString;
        print("html content loaded! " + currentURL!);

    }
    
    func do_exchange(txt: String) {
        _ = call_js("js_show_data", param: "back to JS: Hi there I got your package");
    }
    
    // run javascript on the page with result = call_js("js_fn", param:"rarameter");
    func call_js(function_name: String, param: String) -> String{
        var result = "";
        let full_path = function_name + "('" + param + "')";
        print("Run javascript: \(full_path)");
        
        result = webView.stringByEvaluatingJavaScriptFromString(full_path)!;
        return result;
    }
    
    // popup a screen on top of main screen
    func pop_new_page(txt: String) {
        
        //create webview
        let myWebView:UIWebView = UIWebView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height ))
        
        // format txt to NSURL
        let full_path = NSURL (string: txt);
        // detect the protocol
        let scheme = full_path!.scheme;
        //get filename put of it
        let filename = full_path!.lastPathComponent;
        // get path out of it
        let pathPrefix = txt.stringByDeletingLastPathComponent;
        print(pathPrefix + " " + filename!);
        let root_dir = "";
        //it is local file
        var myurl = NSBundle.mainBundle().URLForResource( filename, withExtension: "", subdirectory: root_dir + pathPrefix);
        //or a link?
        if (scheme == "http") || (scheme == "https") {
            myurl = full_path;
        }
        
        let requestObj = NSURLRequest(URL: myurl!);
        myWebView.loadRequest(requestObj);
        
        // add the webview into the uiviewcontroller
        let screen_name = "popup";
        // load uiview from nib
        let viewController = popup(nibName: screen_name, bundle: nil);
        viewController.view.addSubview(myWebView);
        viewController.view.sendSubviewToBack(myWebView);
        
        // slide in or popup
        
        if navigationController != nil {
            self.navigationController?.pushViewController(viewController, animated: true)
            
        } else {
            presentViewController(viewController, animated: true, completion: nil);
        }
        
    }
    
    func loadPage(){
        let localfilePath = NSBundle.mainBundle().URLForResource("index1.html", withExtension: "", subdirectory: "www");

        let request = NSURLRequest(URL: localfilePath!);
        webView.loadRequest(request);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        if !is_network_on() {  alert("", message: "An internet connection is required to use application"); }
   
     // location setting
        locationManager.delegate = self;
        locationManager.requestWhenInUseAuthorization();
        //locationManager.requestAlwaysAuthorization();
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.startUpdatingLocation();

// webview
        // Set this as the delegate
        // with the line on top 'class ViewController: UIViewController, UIWebViewDelegate'
        // important -> need this line of webview wont trap the js calls
        webView.delegate = self;
        webView.scrollView.bounces = false;

        loadPage();
    }
    
   
    func get_new_page(txt: String) {

     //create webview
        let myWebView:UIWebView = UIWebView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height ))
        
     // format txt to NSURL
        let full_path = NSURL (string: txt);
     // detect the protocol
        let scheme = full_path!.scheme;
     //get filename put of it
        let filename = full_path!.lastPathComponent;
     // get path out of it
        let pathPrefix = txt.stringByDeletingLastPathComponent;
        print(pathPrefix + " " + filename!);
        let root_dir = "";
     //it is local file
        var myurl = NSBundle.mainBundle().URLForResource( filename, withExtension: "", subdirectory: root_dir + pathPrefix);
     //or a link?
        if (scheme == "http") || (scheme == "https") {
            myurl = full_path;
        }
        
        let requestObj = NSURLRequest(URL: myurl!);
         myWebView.loadRequest(requestObj);
        
// add the webview into the uiviewcontroller
        let screen_name = "popup";
        // load uiview from nib
        let viewController = popup(nibName: screen_name, bundle: nil);

  
        viewController.view.addSubview(myWebView);
        viewController.view.sendSubviewToBack(myWebView);

        
        if navigationController != nil {
            self.navigationController?.pushViewController(viewController, animated: true)
        
        } else {
            presentViewController(viewController, animated: true, completion: nil);
        }
       
    };
    
    
//override main view controller
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = true
        super.viewWillAppear(animated);
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        if (navigationController?.topViewController != self) {
            navigationController?.navigationBarHidden = false
        }
        super.viewWillDisappear(animated);
    }
    
    
 
   func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last;
        
        long = location!.coordinate.longitude;
        lat = location!.coordinate.latitude;
        print (lat," , ",long);
     //   locationManager.stopUpdatingLocation();
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Error: " + error.localizedDescription)
    }

    func response_call_1(param:String) {
        //  alert("Bridge", message: param);
        pop_message(param);
        
    }
    
    func send_geolocation() {
        let mystring = String (lat) + " , " + String(long);
        let script = "ios_to_js('\(mystring)')";
        call_js(script, param:"");
    }
    
        
    
    
}

