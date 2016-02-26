//
//  PreferenceSet.swift
//  PreferencePicker
//
//  Created by Kevin Connor on 2/22/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import Foundation
import MediaPlayer

protocol PreferenceSet {
    var items: [PreferenceSetItem] { get set }
    var imported: Bool { get set }
    var created: Bool { get set }
    
    
}

// would love to figure out how to classname this programmatically, e.g. PreferenceSetTypeIds.iTunesPlaylist
class iTunesPlaylistPreferenceSet : PreferenceSet {
    var items = [PreferenceSetItem]()
    var imported = iTunesPreferenceSetType.importable
    var created = iTunesPreferenceSetType.creatable
    
    init(candidateItems: [MPMediaItem]) {
        for item in candidateItems {
            items.append(iTunesPreferenceSetItem(candidateItem: item))
        }
    }
}