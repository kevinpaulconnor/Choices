//
//  ChoosePreferenceViewController.swift
//  PreferencePicker
//
//  Created by Kevin Connor on 2/18/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import UIKit
import MediaPlayer

class ChoosePreferenceViewController: UIViewController {
    @IBOutlet weak var topItemView: UIView!
    @IBOutlet weak var bottomItemView: UIView!
    @IBAction func getNewChoices() {
        self.reset()
    }




    
    var activeSet: PreferenceSet?
    var topItem: PreferenceSetItem?
    var topViewController: ItemChooserViewController?
    var bottomViewController: ItemChooserViewController?
    var bottomItem: PreferenceSetItem?
    let itemsToDisplay = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let barViewController = self.tabBarController as! PreferencePickerTabBarViewController
        activeSet = barViewController.activeSet
        
        self.setItems()
    }
    
    func reset() {
        let player = MPMusicPlayerController.applicationMusicPlayer()
        player.stop()
        self.resetItems()
    }
    
    func resetItems() {
        topViewController!.view.removeFromSuperview()
        topViewController!.removeFromParentViewController()
        bottomViewController!.view.removeFromSuperview()
        bottomViewController!.removeFromParentViewController()
        
        self.setItems()
    }
    
    func setItems() {
        // less awkward if a way to return a tuple here.
        // maybe PreferenceSetBase should just expose getTwoItemsForComparison()
        let psItems = activeSet?.getItemsForComparison(self.itemsToDisplay)
        topItem = psItems![0]
        bottomItem = psItems![1]
        
        topViewController = self.setContainerView(topItemView, item: topItem!)
        bottomViewController = self.setContainerView(bottomItemView, item: bottomItem!)
    }
    
    private struct vcGenerators {
        static let music = {(myVC: ChoosePreferenceViewController) -> UIViewController in
                return myVC.storyboard?.instantiateViewControllerWithIdentifier("iTunesItemController") as! iTunesItemChooserViewController
        }
    }
    
    func setContainerView(containerView: UIView, item: PreferenceSetItem) -> ItemChooserViewController {
        let itemViewController = self.chooserItemControllersByPreferenceSetType() as! ItemChooserViewController
        itemViewController.item = item
        self.addChildViewController(itemViewController)
        itemViewController.view.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height)
        containerView.addSubview(itemViewController.view)
        itemViewController.didMoveToParentViewController(self)
        return itemViewController
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