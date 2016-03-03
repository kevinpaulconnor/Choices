//
//  ChoosePreferenceViewController.swift
//  PreferencePicker
//
//  Created by Kevin Connor on 2/18/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import UIKit

class ChoosePreferenceViewController: UIViewController {
    var activeSet: PreferenceSet?
    @IBOutlet weak var topItemView: UIView!
    let itemsToDisplay = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let topItemViewController = storyboard?.instantiateViewControllerWithIdentifier("iTunesItemController") as! iTunesItemChooserViewController
        self.addChildViewController(topItemViewController)
        topItemViewController.view.frame = CGRectMake(0, 0, self.topItemView.frame.size.width, self.topItemView.frame.size.height)
        self.topItemView.addSubview(topItemViewController.view)
        topItemViewController.didMoveToParentViewController(self)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}