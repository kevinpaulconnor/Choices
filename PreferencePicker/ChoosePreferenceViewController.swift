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
    @IBOutlet weak var bottomItemView: UIView!
    let itemsToDisplay = 2
    override func viewDidLoad() {

        super.viewDidLoad()
        self.setContainerView(topItemView)
        self.setContainerView(bottomItemView)


    }
    
    private struct vcGenerators {
        static let music = {(myVC: ChoosePreferenceViewController) -> UIViewController in
                return myVC.storyboard?.instantiateViewControllerWithIdentifier("iTunesItemController") as! iTunesItemChooserViewController
        }
    }
    
    func setContainerView(containerView: UIView) {
        let itemViewController = self.chooserItemControllersByPreferenceSetType()
        self.addChildViewController(itemViewController)
        itemViewController.view.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height)
        containerView.addSubview(itemViewController.view)
        itemViewController.didMoveToParentViewController(self)
    }
    
    // preference set type tells the view what kind of view controllers to load
    private func chooserItemControllersByPreferenceSetType () -> (UIViewController) {
        var controllerIdentifier: UIViewController?
        switch activeSet!.preferenceSetType {
        case PreferenceSetTypeIds.iTunesPlaylist:
            controllerIdentifier = vcGenerators.music(self)
        default: break
        }
        
        return controllerIdentifier!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}