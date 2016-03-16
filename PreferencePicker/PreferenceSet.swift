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
    func itemCount() -> Int
    func getItemsForComparison(numberToGet: Int) -> [PreferenceSetItem]
    func getItemByIndex(index: Int) -> PreferenceSetItem
    func getAllItems() -> [PreferenceSetItem]
}

//don't want to reach into data store and load everything,
// so let's just show what we need about each, when we're loading
// on second thought, this concept doesn't seem to be viable
// but we'll leave the code around until that proves out...
/*struct minimalSetReference {
    var title: String
    var preferenceSetType: PreferenceSetType
}*/

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

    init(title: String) {
        self.title = title
    }

    func itemCount() -> Int {
        return items.count
    }
    
    // for now, just return a random item from the set's items
    func getItemsForComparison(numberToGet: Int) -> [PreferenceSetItem] {
        var ret = [PreferenceSetItem]()
        for _ in 0..<numberToGet {
            ret.append(self.items[Int(arc4random_uniform(UInt32(self.items.count)))])
        }
        return ret
    }
    
    func getItemByIndex(index: Int) -> PreferenceSetItem {
        return items[index]
    }
    
    func getAllItems() -> [PreferenceSetItem] {
        return items
    }
    
    //Decided to manage all persistence layer api
    //through PreferenceSetBase
    
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
    
    static func save(preferenceSet: PreferenceSet) {
        appDelegate!.dataController!.createSetMO(preferenceSet)
    }
    
    static func load(name: String, type: PreferenceSetType) -> PreferenceSet {
        return appDelegate!.dataController!.load(name, type: type)
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
            items.append(iTunesPreferenceSetItem(candidateItem: item))
        }
    }
}