//
//  PreferenceSet.swift
//  PreferencePicker
//
//  Created by Kevin Connor on 2/22/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import Foundation
import MediaPlayer

// PreferenceSet protocol provides APIs for the presentation
// and modification of PreferenceSet in view controllers
protocol PreferenceSet {
    var title: String {get set }
    var preferenceSetType: String { get set }
    func itemCount() -> Int
    func getItemsForComparison(numberToGet: Int) -> [PreferenceSetItem]
    func getItemByIndex(index: Int) -> PreferenceSetItem
    
}

// PreferenceSetBase holds common logic for determining
// and storing user preferences about the items in the set
class PreferenceSetBase : PreferenceSet {
    var title = String()
    var preferenceSetType = String()
    
    private var items = [PreferenceSetItem]()

    init(title: String) {
        self.title = title
    }

    func itemCount() -> Int {
        return items.count
    }
    
    func getItemsForComparison(numberToGet: Int) -> [PreferenceSetItem] {
        
        return [PreferenceSetItem]()
    }
    
    func getItemByIndex(index: Int) -> PreferenceSetItem {
        return items[index]
    }
}

// Preference Sets should conform to PreferenceSet, and subclass PreferenceSetOperator

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