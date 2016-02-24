//
//  PreferenceSetTypeManager.swift
//  PreferencePicker
//
//  API for Preference Set Types for View Controllers
//  Created by Kevin Connor on 2/22/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import Foundation
import MediaPlayer

class PreferenceSetTypeManager {
    private let types = [PreferenceSetType](
        arrayLiteral: iTunesPreferenceSetType(id:PreferenceSetTypeIds.iTunesPlaylist,
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

class PreferenceSetType {
    var importable: Bool = true
    var creatable: Bool = false
    var description: String?
    var id: String?
    
    init(id: String, description: String) {
        self.id = id
        self.description = description
    }
    
    class func getAvailableSetsForImport() {
        
    }

}

class iTunesPreferenceSetType: PreferenceSetType {
    
    override init(id: String, description: String) {
        super.init(id: id, description: description)
    }
    
    class override func getAvailableSetsForImport() {
        // var albumPredicate: MPMediaPropertyPredicate =
        //MPMediaPropertyPredicate(value: MPMediaType.Music, forProperty: MPMediaItemPropertyMediaType)
        
        var playlists = MPMediaQuery.playlistsQuery()
        
        for item in playlists.items! {
            print("\(item)")
        }
        
    }
}