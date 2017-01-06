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
    @IBAction func aboutTheSame(_ sender: UIButton) {
        setComparison(0)
        self.reset()
    }
    @IBAction func getNewChoices() {
        self.reset()
    }

    var activeSet: PreferenceSet?
    var topItem: PreferenceSetItem?
    var topViewController: ItemChooserViewController?
    var bottomViewController: ItemChooserViewController?
    var viewCenter: CGPoint?
    var viewAnimator: UIViewPropertyAnimator?
    var bottomItem: PreferenceSetItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let barViewController = self.tabBarController as! PreferencePickerTabBarViewController
        activeSet = barViewController.activeSet

        self.setItems()
        self.setPanOnItemViews(topItemView)
        self.setPanOnItemViews(bottomItemView)
    }
    
    func setPanOnItemViews(_ view: UIView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(ChoosePreferenceViewController.respondToPanGesture(gesture:)))
        view.addGestureRecognizer(pan)
    }
    
    
    func respondToPanGesture(gesture: UIPanGestureRecognizer) {
        let target = gesture.view!
        
        switch gesture.state {
        case .began:
            viewCenter = target.center
        case .changed:
            let translation = gesture.translation(in: self.view)
            target.center = CGPoint(x: viewCenter!.x + translation.x, y: viewCenter!.y + translation.y)
        case .ended:
            let v = gesture.velocity(in: target)
            // FIXME: 500 is a magic number
            // if we're moving fast enough left or right at end of pan, animate view off screen
            // and register the relevant comparison
            var xValueToAnimateTo = self.viewCenter!.x
            var winningMemoryId:MemoryId? = nil
            switch v.x {
            case 1000 ..< .greatestFiniteMagnitude:
                xValueToAnimateTo = self.viewCenter!.x + 500
                winningMemoryId = getWinningIdFromPanDirection(target: target, xDirection: .greatestFiniteMagnitude)
            case -.greatestFiniteMagnitude ..< -1000:
                xValueToAnimateTo = self.viewCenter!.x + -500
                winningMemoryId = getWinningIdFromPanDirection(target: target, xDirection: -.greatestFiniteMagnitude)
            // really wish this wasn't required
            default: break
            }
            
            viewAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut)
            let animationObject = { target.center = CGPoint(x: xValueToAnimateTo, y: self.viewCenter!.y) }
            viewAnimator!.addAnimations(animationObject)
            viewAnimator!.addCompletion({ _ in self.resolvePan(winningId: winningMemoryId) })
            viewAnimator!.startAnimation()
        default: break
        }
    }
    
    func getWinningIdFromPanDirection(target: UIView, xDirection: CGFloat) -> MemoryId {
        switch target.tag {
        case topItemView.tag:
            if xDirection == .greatestFiniteMagnitude { return topItem!.memoryId } else {
                return bottomItem!.memoryId
            }
        case bottomItemView.tag:
            if xDirection == -.greatestFiniteMagnitude { return bottomItem!.memoryId } else {
                return topItem!.memoryId
            }
        default: fatalError()
        }
    }
    
    func resolvePan(winningId: MemoryId?) {
        guard let id = winningId else { return }
        
        setComparison(id)
        self.reset()
    }
    
    // hate 0 for draw as magic number, to-do find a good spot to un-magic it
    func setComparison(_ winningItemId: MemoryId) {
        let id1 = topItem!.memoryId
        let id2 = bottomItem!.memoryId
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
    // itemChooser grabbed control of, e.g. the music player. Let the other item
    // chooser know so that it can update as necessary
    func itemChooserGrabbedControl(controllingItem: ItemChooserViewController) {
        if (controllingItem == topViewController!) {
            bottomViewController!.updateAfterLosingControl()
        } else {
            topViewController!.updateAfterLosingControl()
        }
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
    
    fileprivate struct vcGenerators {
        static let music = {(myVC: ChoosePreferenceViewController) -> UIViewController in
                return myVC.storyboard?.instantiateViewController(withIdentifier: "iTunesItemController") as! iTunesItemChooserViewController
        }
    }
    
    func setContainerView(_ containerView: UIView, tag: Int, item: PreferenceSetItem) -> ItemChooserViewController {
        let itemViewController = self.chooserItemControllersByPreferenceSetType() as! ItemChooserViewController
        itemViewController.item = item
        self.addChildViewController(itemViewController)
        itemViewController.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: containerView.frame.size.height)
        containerView.tag = tag
        containerView.addSubview(itemViewController.view)
        itemViewController.didMove(toParentViewController: self)
        return itemViewController
    }
    
    // preference set type tells the view what kind of view controllers to load
    fileprivate func chooserItemControllersByPreferenceSetType () -> (UIViewController) {
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
