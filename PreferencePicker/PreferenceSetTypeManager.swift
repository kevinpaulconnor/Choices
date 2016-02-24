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
        arrayLiteral: iTunesPreferenceSetType()
    )
    
    func allPreferenceSetTypes() -> [PreferenceSetType] {
        return types
    }
    
    //func getSetType(psId: PreferenceSetTypeIds) -> PreferenceSetType {
    //    return types[psId.hashValue]
    //}
    
}

struct PreferenceSetTypeIds {
    static let iTunesPlaylist = "iTunesPlayList"
}

protocol PreferenceSetType {
    var importable: Bool { get }
    var creatable: Bool { get }
    var description: String { get }
    var id: String { get }

    func getAvailableSetsForImport() -> [MPMediaItemCollection]
    
}

class iTunesPreferenceSetType: PreferenceSetType {
    var importable = true
    var creatable = false
    var description = "iTunes Playlist"
    var id = PreferenceSetTypeIds.iTunesPlaylist
    
    func getAvailableSetsForImport() -> [MPMediaPlaylist] {
        // var albumPredicate: MPMediaPropertyPredicate =
        //MPMediaPropertyPredicate(value: MPMediaType.Music, forProperty: MPMediaItemPropertyMediaType)
        
        var playlist = MPMediaQuery.playlistsQuery()
        for collection in playlists.collections! {
            var playlist = collection as! MPMediaPlaylist
            print("\(playlist.name!)")
        }
        
    }
}