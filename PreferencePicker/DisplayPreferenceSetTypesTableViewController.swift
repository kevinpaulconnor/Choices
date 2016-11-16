//
//  DisplayPreferenceSetTypesTableViewController.swift
//  PreferencePicker
//
//  Created by Kevin Connor on 2/19/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import UIKit

class DisplayPreferenceSetTypesTableViewController: UITableViewController {
    // with the wisdom of some weeks working on this,
    // might be better to rework Type Manager as a singleton with static methods
    var types:[PreferenceSetType]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // might want to investigate PSTM as a struct and/or not having to instantiate here
        types = PreferenceSetTypeManager.allPreferenceSetTypes()
        
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return types!.count
    }

    fileprivate struct Storyboard {
        static let CellReuseIdentifier = "PreferenceSetType"
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = PreferenceSetTypeColors.getBGColorForTableCell(types![indexPath.row].id)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellReuseIdentifier, for: indexPath)
        
        cell.textLabel?.text = types![indexPath.row].description

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
        if ( segue.identifier == "ChooseImportType") {
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                let preferenceSetVC = segue.destination as! DisplayCandidatePreferenceSetsTableViewController
                preferenceSetVC.title = types![indexPath.row].description
                preferenceSetVC.preferenceSetType = types![indexPath.row]
            }
        }
    }

}
