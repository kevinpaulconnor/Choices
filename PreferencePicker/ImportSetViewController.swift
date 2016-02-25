//
//  ImportSetViewController.swift
//  PreferencePicker
//
//  Created by Kevin Connor on 2/24/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import UIKit

class ImportSetViewController: UIViewController {

    @IBOutlet weak var candidateSetTitleDisplay: UILabel!
    @IBOutlet weak var candidateSetItemCountDisplay: UILabel!
    var candidateSetTitle: String?
    var candidateSetItemCount: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        candidateSetTitleDisplay.text = candidateSetTitle!
        candidateSetItemCountDisplay.text = candidateSetItemCount!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
