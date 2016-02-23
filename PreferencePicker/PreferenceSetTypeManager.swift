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
    let types = [PreferenceSetType](
        arrayLiteral: PreferenceSetType(id:PreferenceSetTypeIds.iTunesPlaylist,
                        description: "iTunes Playlist"
        )
    )

    struct PreferenceSetTypeIds {
        static let iTunesPlaylist = "iTunesPlayList"
    }
    
    func preferenceSetTypeDescriptions() -> [String] {
        var descriptions = [String]()
        for type in types {
            descriptions.append(type.description)
        }
        return descriptions
    }
    
    func getSetType(psId: PreferenceSetTypeIds) -> PreferenceSetType {
        return types[psId.hashValue]
    }
    
}