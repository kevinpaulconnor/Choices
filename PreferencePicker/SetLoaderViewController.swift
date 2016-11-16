//
//  SetLoaderViewController.swift
//  PreferencePicker
//
//  Created by Kevin Connor on 2/18/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import UIKit

class SetLoaderViewController: UIViewController {

    @IBOutlet weak var currentSetLabel: UILabel!
    
    var activeSet: PreferenceSet?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if activeSet != nil {
            currentSetLabel.text = activeSet!.title
        } else {
            currentSetLabel.text = "(no set loaded)"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

