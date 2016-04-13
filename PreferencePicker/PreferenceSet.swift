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
import Photos

// PHAsset are persistently identified by strings
// MPMediaItem are persistently identified by UInt64
// so, create an in-memory id on import/load
// and only use the persistent ids for persistence layer
// typealias in case Int is no good sometime in the future
typealias MemoryId = Int

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
    func getNextMemoryId() -> Int
    func getAllItems() -> [PreferenceSetItem]
    func registerComparison(id1: MemoryId, id2: MemoryId, result: MemoryId)
    func updateRatings()
    func returnSortedPreferenceScores() -> [(MemoryId, Double)]
    func getItemById(id: MemoryId) -> PreferenceSetItem?
    func getPreferenceScoreById(id: MemoryId) -> PreferenceScore?
    func getAllComparisons() -> [NSDate: Comparison]
    func getAllPreferenceScores() -> [MemoryId: PreferenceScore]
    func restoreScoreManagerScores(candidateComparisons: [Comparison], candidateScores: [MemoryId: Double])
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
    private var keyedItems = [MemoryId : PreferenceSetItem]()
    private var memoryId = 0
    
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
    
    func getNextMemoryId() -> Int {
        let ret = memoryId
        memoryId = memoryId + 1
        return ret
    }
    
    func getItemById(id: MemoryId) -> PreferenceSetItem? {
        return keyedItems[id]
    }
    
    func getAllItems() -> [PreferenceSetItem] {
        return items
    }
    
    func registerComparison(id1: MemoryId, id2: MemoryId, result: MemoryId) {
        self.scoreManager.createAndAddComparison(id1, id2: id2, result: result)
    }
    
    func getAllComparisons() -> [NSDate: Comparison] {
        return self.scoreManager.getAllComparisons()
    }
    
    func getAllPreferenceScores() -> [MemoryId: PreferenceScore] {
        return self.scoreManager.getAllPreferenceScores()
    }
    
    func getPreferenceScoreById(id: MemoryId) -> PreferenceScore? {
        return self.scoreManager.getPreferenceScoreById(id)
    }
    
    func updateRatings() {
        self.scoreManager.update()
        //might need to update model here...
        PreferenceSetBase.update(self)

    }
    
    func returnSortedPreferenceScores() -> [(MemoryId, Double)] {
        return self.scoreManager.getUpdatedSortedPreferenceScores()
    }
 
    func restoreScoreManagerScores(candidateComparisons: [Comparison], candidateScores: [MemoryId: Double]) {
        scoreManager.restoreComparisons(candidateComparisons, candidateScores: candidateScores)
    }
    
    //Decided to manage all persistence layer api
    //through PreferenceSetBase. That will make it easier to
    //swap persistence layers
    
    // not crazy about how these build* methods wound up...
    // among other things, they will be fragile as MemoryId typedef changes
    // decided to live with it for now
    static func buildComparisonArrayFromMOs(managedComparisons: [ComparisonMO]) -> [Comparison] {
        var comparisons = [Comparison]()
        for managedComparison in managedComparisons {
            let items = managedComparison.preferenceSetItem!.allObjects as! [PreferenceSetItemMO]
            comparisons.append(Comparison(id1: items[0].id!.integerValue, id2: items[1].id!.integerValue, result: managedComparison.result!.integerValue, timestamp: managedComparison.timestamp!))
        }
        return comparisons
    }
    
    static func buildScoreArrayFromMOs(managedScores: [PreferenceScoreMO]) -> [MemoryId: Double] {
        var output = [MemoryId: Double]()
        for managedScore in managedScores {
            output[managedScore.preferenceSetItem!.id!.integerValue] = managedScore.score!.doubleValue
        }
        return output
    }
    
    static func updateActiveSetForModel(setMO: PreferenceSetMO) {
        appDelegate!.dataController!.updateActiveSetMO(setMO)
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
            let newiTunesItem = iTunesPreferenceSetItem(candidateItem: item, set: self)
            items.append(newiTunesItem)
            keyedItems[newiTunesItem.memoryId] = newiTunesItem
        }

        self.scoreManager.initializeComparisons(items)
    }
    
}

// would love to figure out how to classname this programmatically, e.g. PreferenceSetTypeIds.iTunesPlaylist
class photoMomentPreferenceSet : PreferenceSetBase {
    
    init(candidateItems: [PHAsset], title: String) {
        super.init(title: title)
        super.preferenceSetType = PreferenceSetTypeIds.iTunesPlaylist
        
        for item in candidateItems {
            let newItem = photoMomentPreferenceSetItem(candidateItem: item, set: self)
            items.append(newItem)
            keyedItems[newItem.memoryId] = newItem
        }
        
        self.scoreManager.initializeComparisons(items)
    }
    
}