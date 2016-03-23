//
//  PreferencePickerTabBarViewController.swift
//  PreferencePicker
//
//  Created by Kevin Connor on 2/29/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import UIKit

class PreferencePickerTabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    var activeSet: PreferenceSet?
    //not crazy about this. always want it to be nil, except when I'm
    //in the act of loading
    var candidateMO: PreferenceSetMO?
    private struct TabIndex {
        static let Load = 0
        static let Second = 1
        static let ActiveSet = 2
        static let ViewScores = 3
    }
    
    // after importing a set, set ActiveSet to active tab, and reset TabIndex.Load
    @IBAction func importedSet(segue: UIStoryboardSegue) {
        let importController = segue.sourceViewController as! ImportSetViewController
        self.activeSet = importController.importSet()
 
        self.viewControllers![TabIndex.Load] = storyboard!.instantiateViewControllerWithIdentifier("LoadNavigationController")
        self.goToActiveSetView()
    }
    
    // after loading a previously saved set, associate MediaItems with active set,
    // create active set, move to ActiveSet tab
    @IBAction func loadedSet(segue: UIStoryboardSegue) {
        if let managedSet = self.candidateMO {
            let managedItems = managedSet.preferenceSetItem!.allObjects as! [PreferenceSetItemMO]
            let candidateSet = PreferenceSetBase.buildMediaItemArrayFromMOs(managedItems)
            let type = PreferenceSetTypeManager.getSetType(managedSet.preferenceSetType!)
            self.activeSet = type.createPreferenceSet(candidateSet, title: managedSet.title!)
            self.candidateMO = nil
            self.goToActiveSetView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func goToActiveSetView() {
        let navController = self.viewControllers![TabIndex.ActiveSet] as! UINavigationController
        let ActiveSetVC = navController.topViewController as! DisplayActiveSetTableViewController
        ActiveSetVC.activeSet = self.activeSet
        ActiveSetVC.title = self.activeSet!.title
        self.selectedIndex = TabIndex.ActiveSet
    }
    
    func tabBarController(tabBarController: UITabBarController,
        shouldSelectViewController viewController: UIViewController) -> Bool {
        var allow = true
            // do not allow ActiveSet view to load if there is no active set
            if let restId = viewController.restorationIdentifier {
                if activeSet == nil && (restId == "ActiveSet" || restId == "ChoosePreference" || restId == "DisplayScores") {
                        allow = false
                        func alertHandler(action: UIAlertAction) -> Void {
                            self.selectedIndex = TabIndex.Load
                        }
                        let alert = UIAlertController(
                            title: "No Active Set",
                            message: "Load or Create a Preference Set",
                            preferredStyle: UIAlertControllerStyle.Alert
                        )
                        alert.addAction(UIAlertAction(
                            title: "Create Or Load A Set",
                            style: UIAlertActionStyle.Default,
                            handler: alertHandler
                            ))
                        
                        presentViewController(alert, animated: true, completion: nil)
                }
                // propogate activeSet to DisplayScores view
                if activeSet != nil && restId == "DisplayScores" {
                    let displayScoresVC = viewController as! DisplayScoresTableViewController
                    displayScoresVC.activeSet = self.activeSet
                }
                // if we're not going to the ratings view, ensure that our ratings are up to date
                if restId != "ActiveSet" {
                    activeSet!.updateRatings()
                }
            }
        return allow
    }
}
