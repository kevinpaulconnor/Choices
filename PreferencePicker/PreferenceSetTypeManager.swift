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
    static let types = [PreferenceSetTypeIds.iTunesPlaylist: iTunesPreferenceSetType()]
    
    static func allPreferenceSetTypes() -> [PreferenceSetType] {
        var typeArray = [PreferenceSetType]()
        for type in types.values {
            typeArray.append(type)
        }
        return typeArray
    }
    
    static func getSetType(psId: String) -> PreferenceSetType {
       return types[psId]!
    }
    
}

struct PreferenceSetTypeIds {
    static let iTunesPlaylist = "iTunesPlayList"
}



protocol PreferenceSetType {
    static var importable: Bool { get }
    static var creatable: Bool { get }
    var description: String { get }
    var id: String { get }
    
    func getAvailableSetsForImport() -> [MPMediaItemCollection]
    func displayNameForCandidateSet(candidateSet: MPMediaItemCollection) -> String
    func nameForItemsOfThisType(count: Int) -> String
    func createPreferenceSet(candidateSet: [MPMediaItem], title: String) -> PreferenceSet
    func importPreferenceSet(candidateSet: [MPMediaItem], title: String) -> PreferenceSet
}

class iTunesPreferenceSetType: PreferenceSetType {
    static var importable = true
    static var creatable = false
    var description = "iTunes Playlist"
    var id = PreferenceSetTypeIds.iTunesPlaylist
    
    func getAvailableSetsForImport() -> [MPMediaItemCollection] {
        // var albumPredicate: MPMediaPropertyPredicate =
        //MPMediaPropertyPredicate(value: MPMediaType.Music, forProperty: MPMediaItemPropertyMediaType)
        
        return MPMediaQuery.playlistsQuery().collections!
    }
    
    func displayNameForCandidateSet(candidateSet: MPMediaItemCollection) -> String {
        let playlist = candidateSet as! MPMediaPlaylist
        return playlist.name!
    }
    
    func nameForItemsOfThisType(count: Int) -> String {
        return (count > 1 ? "songs" : "song")
    }
    
    func createPreferenceSet(candidateSet: [MPMediaItem], title: String) -> PreferenceSet {
        return iTunesPlaylistPreferenceSet(candidateItems: candidateSet, title: title, restore: false)
    }
    
    func importPreferenceSet(candidateSet: [MPMediaItem], title: String) -> PreferenceSet {
        return iTunesPlaylistPreferenceSet(candidateItems: candidateSet, title: title, restore: true)
    }
    
}