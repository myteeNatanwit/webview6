//
//  screen2.swift
//  Konvo
//
//  Created by Michael Tran on 26/10/2015.
//  Copyright © 2015 intcloud. All rights reserved.
//

import UIKit

class screen2: UIViewController {

    @IBOutlet weak var btn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
      //  btn.layer.zPosition = 10000;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btn1_onclick(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: {});
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
