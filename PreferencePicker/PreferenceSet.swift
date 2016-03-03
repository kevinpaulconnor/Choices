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
    
    func getItemsForComparison(numberToGet: Int) -> [PreferenceSetItem]
    
}

// PreferenceSetBase holds common logic for determining
// and storing user preferences about the items in the set
class PreferenceSetBase : PreferenceSet {
    var title = String()
    var items = [PreferenceSetItem]()
    
    init(title: String) {
        self.title = title
    }

    
    func getItemsForComparison(numberToGet: Int) -> [PreferenceSetItem] {
        
        return [PreferenceSetItem]()
    }
}

// Preference Sets should conform to PreferenceSet, and subclass PreferenceSetOperator

// would love to figure out how to classname this programmatically, e.g. PreferenceSetTypeIds.iTunesPlaylist
class iTunesPlaylistPreferenceSet : PreferenceSetBase {

    init(candidateItems: [MPMediaItem], title: String) {
        super.init(title: title)
        
        for item in candidateItems {
            items.append(iTunesPreferenceSetItem(candidateItem: item))
        }
    }
}