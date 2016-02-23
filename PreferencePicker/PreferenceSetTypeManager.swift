//
//  PreferenceSetTypeManager.swift
//  PreferencePicker
//
//  API for Preference Set Types for View Controllers
//  Created by Kevin Connor on 2/22/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import Foundation

class PreferenceSetTypeManager {
    private let types = [PreferenceSetType](
        arrayLiteral: PreferenceSetType(id:PreferenceSetTypeIds.iTunesPlaylist,
                        description: "iTunes Playlist"
        )
    )

    struct PreferenceSetTypeIds {
        static let iTunesPlaylist = "iTunesPlayList"
    }
    
    func allPreferenceSetTypes() -> [PreferenceSetType] {
        return types
    }
    
    //func getSetType(psId: PreferenceSetTypeIds) -> PreferenceSetType {
    //    return types[psId.hashValue]
    //}
    
}