//
//  PreferenceSet.swift
//  PreferencePicker
//
//  Created by Kevin Connor on 2/22/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import Foundation
import MediaPlayer
import CoreData

// PreferenceSet protocol provides APIs for the presentation
// and modification of PreferenceSet in view controllers and
// persistence layer
protocol PreferenceSet {
    var title: String {get set }
    var preferenceSetType: String { get set }
    
    //might want more flexibility here eventually by implementing scoreManager protocol
    var scoreManager: ELOManager { get set }
    func itemCount() -> Int
    func getItemsForComparison() -> [PreferenceSetItem]
    func getItemByIndex(index: Int) -> PreferenceSetItem
    func getAllItems() -> [PreferenceSetItem]
    func registerComparison(id1: UInt64, id2: UInt64, result: UInt64)
    func updateRatings()
    func returnSortedPreferenceScores() -> [(UInt64, Double)]
    func getItemById(id: UInt64) -> PreferenceSetItem?
    func getPreferenceScoreById(id: UInt64) -> PreferenceScore?
    func getAllComparisons() -> [NSDate: Comparison]
    func getAllPreferenceScores() -> [UInt64: PreferenceScore]
}

// PreferenceSetBase holds common logic for determining
// and storing user preferences about the items in the set
// and common PreferenceSet persistence layer accessors
class PreferenceSetBase : PreferenceSet {
    var title = String()
    var preferenceSetType = String()
    static var appDelegate =
    UIApplication.sharedApplication().delegate as? AppDelegate
    var scoreManager = ELOManager()
    private var items = [PreferenceSetItem]()
    private var keyedItems = [UInt64 : PreferenceSetItem]()
    
    init(title: String) {
        self.title = title
    }

    func itemCount() -> Int {
        return items.count
    }

    func getItemsForComparison() -> [PreferenceSetItem] {
        let ids = scoreManager.getIdsForComparison()
        return [keyedItems[ids[0]]!, keyedItems[ids[1]]!]
    }
    
    func getItemByIndex(index: Int) -> PreferenceSetItem {
        return items[index]
    }
    
    func getItemById(id: UInt64) -> PreferenceSetItem? {
        return keyedItems[id]
    }
    
    func getAllItems() -> [PreferenceSetItem] {
        return items
    }
    
    func registerComparison(id1: UInt64, id2: UInt64, result: UInt64) {
        self.scoreManager.createAndAddComparison(id1, id2: id2, result: result)
    }
    
    func getAllComparisons() -> [NSDate: Comparison] {
        return self.scoreManager.getAllComparisons()
    }
    
    func getAllPreferenceScores() -> [UInt64: PreferenceScore] {
        return self.scoreManager.getAllPreferenceScores()
    }
    
    func getPreferenceScoreById(id: UInt64) -> PreferenceScore? {
        return self.scoreManager.getPreferenceScoreById(id)
    }
    
    func updateRatings() {
        self.scoreManager.update()
        //might not want to update model every time...
        PreferenceSetBase.update(self)
    }
    
    func returnSortedPreferenceScores() -> [(UInt64, Double)] {
        return self.scoreManager.getUpdatedSortedPreferenceScores()
    }
    
    //Decided to manage all persistence layer api
    //through PreferenceSetBase. That will make it easier to
    //swap persistence layers
    
    static func buildMediaItemArrayFromMOs(managedItems: [PreferenceSetItemMO]) -> [MPMediaItem] {
        let mediaItemArray = MPMediaQuery.songsQuery().items!
        var outputArray = [MPMediaItem]()
        for mediaItem in mediaItemArray {
            let castedId = NSNumber(unsignedLongLong: mediaItem.persistentID)
            if managedItems.contains({$0.id! == castedId}) {
                outputArray.append(mediaItem)
            }
        }
        return outputArray
    }
    
    static func create(preferenceSet: PreferenceSet) {
        appDelegate!.dataController!.createSetMO(preferenceSet)
    }
    
    static func update(preferenceSet: PreferenceSet) {
        appDelegate!.dataController!.updateSetMO(preferenceSet)
    }
    
    static func getAllSavedSets() -> [PreferenceSetMO] {
        return appDelegate!.dataController!.getAllSavedSets()
    }
}

// Preference Sets should conform to PreferenceSet, and subclass PreferenceSetBase

// would love to figure out how to classname this programmatically, e.g. PreferenceSetTypeIds.iTunesPlaylist
class iTunesPlaylistPreferenceSet : PreferenceSetBase {
 
    init(candidateItems: [MPMediaItem], title: String) {
        super.init(title: title)
        super.preferenceSetType = PreferenceSetTypeIds.iTunesPlaylist
        
        for item in candidateItems {
            let newiTunesItem = iTunesPreferenceSetItem(candidateItem: item)
            items.append(newiTunesItem)
            keyedItems[item.persistentID] = newiTunesItem
        }
        
        self.scoreManager.initializeComparisons(candidateItems)
    }
}