//
//  popup.swift
//  Konvo
//
//  Created by Michael Tran on 27/10/2015.
//  Copyright © 2015 intcloud. All rights reserved.
//

import UIKit

class popup: UIViewController {

    @IBOutlet weak var btn_x: UIButton!
    override func viewDidLoad() {
       
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
    }

    @IBAction func btn_x_onclick(sender: AnyObject) {
     self.dismissViewControllerAnimated(true, completion: {});
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
