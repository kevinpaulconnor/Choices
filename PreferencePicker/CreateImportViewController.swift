//
//  CreateImportViewController.swift
//  PreferencePicker
//
//  Created by Kevin Connor on 12/30/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import UIKit
import MediaPlayer

class CreateImportViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func checkAuthStatusAndExecute() -> Bool {
        let status = MPMediaLibrary.authorizationStatus()
        if (status == MPMediaLibraryAuthorizationStatus.authorized)
        {
            return true
        }
        return false
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if ( segue.identifier == "ImportASet") {
            //FIXME: Handle case where user has previously denied media library access
            if (!checkAuthStatusAndExecute()) {
                MPMediaLibrary.requestAuthorization({_ in
                    
                });
            }
        }
    }
}
