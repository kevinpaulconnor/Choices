//
//  PreferencePickerTabBarViewController.swift
//  PreferencePicker
//
//  Created by Kevin Connor on 2/29/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import UIKit

class PreferencePickerTabBarViewController: UITabBarController {
    
    var activeSet: PreferenceSet?

    @IBAction func importedSet(segue: UIStoryboardSegue) {
        let importController = segue.sourceViewController as! ImportSetViewController
        self.activeSet = importController.importSet()
        let navController = self.viewControllers![2] as! UINavigationController
        let ActiveSetVC = navController.topViewController as! DisplayActiveSetTableViewController
        ActiveSetVC.activeSet = self.activeSet
        ActiveSetVC.title = self.activeSet!.title
        self.selectedIndex = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
