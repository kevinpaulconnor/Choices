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
    @IBAction func aboutTheSame(sender: UIButton) {
        sendComparison(0)
        self.reset()
    }
    @IBAction func getNewChoices() {
        self.reset()
    }



    var activeSet: PreferenceSet?
    var topItem: PreferenceSetItem?
    var topViewController: ItemChooserViewController?
    var bottomViewController: ItemChooserViewController?
    var bottomItem: PreferenceSetItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let barViewController = self.tabBarController as! PreferencePickerTabBarViewController
        activeSet = barViewController.activeSet

        self.setItems()
        self.setSwipeOnItemViews(topItemView)
        self.setSwipeOnItemViews(bottomItemView)
    }
    
    func setSwipeOnItemViews(view: UIView) {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(swipeRight)
    }
    
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            var id = topItem!.mediaItem.persistentID
            if gesture.view!.tag == bottomItemView.tag {
                id = bottomItem!.mediaItem.persistentID
            }
            sendComparison(id)
            // should the music stop if it's playing on a swipe?
            self.reset()
        }
    }
    
    // hate 0 for draw as magic number, to-do find a good spot to un-magic it
    func sendComparison(winningItemId: UInt64) {
        let id1 = topItem!.mediaItem.persistentID
        let id2 = bottomItem!.mediaItem.persistentID
        activeSet!.registerComparison(id1, id2: id2, result: winningItemId)
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
        let psItems = activeSet?.getItemsForComparison()
        topItem = psItems![0]
        bottomItem = psItems![1]
        
        topViewController = self.setContainerView(topItemView, tag: 1, item: topItem!)
        bottomViewController = self.setContainerView(bottomItemView, tag: 2, item: bottomItem!)
    }
    
    private struct vcGenerators {
        static let music = {(myVC: ChoosePreferenceViewController) -> UIViewController in
                return myVC.storyboard?.instantiateViewControllerWithIdentifier("iTunesItemController") as! iTunesItemChooserViewController
        }
    }
    
    func setContainerView(containerView: UIView, tag: Int, item: PreferenceSetItem) -> ItemChooserViewController {
        let itemViewController = self.chooserItemControllersByPreferenceSetType() as! ItemChooserViewController
        itemViewController.item = item
        self.addChildViewController(itemViewController)
        itemViewController.view.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height)
        containerView.tag = tag
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