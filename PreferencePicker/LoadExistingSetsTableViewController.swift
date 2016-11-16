//
//  LoadExistingSetsTableViewController.swift
//  PreferencePicker
//
//  Created by Kevin Connor on 3/9/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import UIKit

class LoadExistingSetsTableViewController: UITableViewController {
    // it feels kludgy that i'm interacting with both PreferenceSetBase
    // and PreferenceSetMO here. Should I just drive the whole thing
    // from PreferenceSetMO? That seems wrong too.
    var savedSets: [PreferenceSetMO]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        savedSets = PreferenceSetBase.getAllSavedSets()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return savedSets!.count
    }
    
    fileprivate struct Storyboard {
        static let CellReuseIdentifier = "ChooseSavedSetCell"
    }

    fileprivate func candidateSetTitleForDisplay(_ indexPath: IndexPath) -> String {
        return savedSets![indexPath.row].title!
    }
    
    fileprivate func candidateSetTypeForDisplay(_ indexPath: IndexPath) -> String {
        return savedSets![indexPath.row].preferenceSetType!
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseSavedSetCell", for: indexPath)

        cell.textLabel?.text = self.candidateSetTitleForDisplay(indexPath)
        cell.detailTextLabel?.text = self.candidateSetTypeForDisplay(indexPath)

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if ( segue.identifier == "chosenExistingSetToActivate") {
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                let tabBarVC = segue.destination as! PreferencePickerTabBarViewController
                tabBarVC.candidateMO = savedSets![indexPath.row]
            }
        }
    }

}
