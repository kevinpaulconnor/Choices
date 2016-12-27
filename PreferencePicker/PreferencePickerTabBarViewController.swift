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
    fileprivate struct TabIndex {
        static let Load = 0
        static let Second = 1
        static let ActiveSet = 2
        static let ViewScores = 3
    }
    
    // after importing a set, set ActiveSet to active tab, and reset TabIndex.Load
    @IBAction func importedSet(_ segue: UIStoryboardSegue) {
        let importController = segue.source as! ImportSetViewController
        self.activeSet = importController.importSet()
 
        self.viewControllers![TabIndex.Load] = storyboard!.instantiateViewController(withIdentifier: "LoadNavigationController")
        self.goToActiveSetView()
    }
    
    // after loading a previously saved set, associate MediaItems with active set,
    // create active set, move to ActiveSet tab
    // this work should probably be managed at the PreferenceSet or PreferenceSetBase level
    @IBAction func loadedSet(_ segue: UIStoryboardSegue) {
        if let managedSet = self.candidateMO {
            let managedItems = managedSet.preferenceSetItem!.allObjects as! [PreferenceSetItemMO]
            let managedComparisons = managedSet.comparison!.allObjects as! [ComparisonMO]
            let managedScores = managedSet.preferenceScore!.allObjects as! [PreferenceScoreMO]
            
            let type = PreferenceSetTypeManager.getSetType(managedSet.preferenceSetType!)
            let candidateSet = type.createPreferenceItemCollectionFromMOs(managedItems)
            self.activeSet = type.createPreferenceSet(candidateSet, title: managedSet.title!)
            let candidateComparisons = activeSet!.buildComparisonArrayFromMOs(managedComparisons)
            let candidateScores = activeSet!.buildScoreArrayFromMOs(managedScores)
            activeSet!.restoreScoreManagerScores(candidateComparisons, candidateScores: candidateScores)
            PreferenceSetBase.updateActiveSetForModel(candidateMO!)
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
    
    fileprivate func goToActiveSetView() {
        let navController = self.viewControllers![TabIndex.ActiveSet] as! UINavigationController
        let ActiveSetVC = navController.topViewController as! DisplayActiveSetTableViewController
        ActiveSetVC.activeSet = self.activeSet
        ActiveSetVC.title = self.activeSet!.title
        self.selectedIndex = TabIndex.ActiveSet
    }
    
    fileprivate func setupLoadSetView() {
        let navController = self.viewControllers![TabIndex.Load] as! UINavigationController
        let SetLoaderVC = navController.topViewController as! SetLoaderViewController
        SetLoaderVC.activeSet = self.activeSet
    }
    
    func tabBarController(_ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController) -> Bool {
        var allow = true
            // do not allow ActiveSet view to load if there is no active set
            if let restId = viewController.restorationIdentifier {
                if activeSet == nil && (restId == "ActiveSet" || restId == "ChoosePreference" || restId == "DisplayScores") {
                        allow = false
                        func alertHandler(_ action: UIAlertAction) -> Void {
                            self.selectedIndex = TabIndex.Load
                        }
                        let alert = UIAlertController(
                            title: "No Active Set",
                            message: "Load or Create a Preference Set",
                            preferredStyle: UIAlertControllerStyle.alert
                        )
                        alert.addAction(UIAlertAction(
                            title: "Create Or Load A Set",
                            style: UIAlertActionStyle.default,
                            handler: alertHandler
                            ))
                        
                        present(alert, animated: true, completion: nil)
                }
                // propogate activeSet to DisplayScores view
                if activeSet != nil && restId == "DisplayScores" {
                    let displayScoresVC = viewController as! DisplayScoresTableViewController
                    displayScoresVC.activeSet = self.activeSet
                }
                // propogate activeSet to LoadSet view
                // there's got to be a better way to combine this with DisplayScores
                if activeSet != nil && restId == "LoadNavigationController" {
                    setupLoadSetView()
                }
                // if we're not going to the ratings view, ensure that our ratings are up to date
                if activeSet != nil && restId != "ActiveSet" {
                    activeSet!.updateRatings()
                }
            }
        return allow
    }
}
