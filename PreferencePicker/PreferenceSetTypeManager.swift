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
    static var importable: Bool { get }
    static var creatable: Bool { get }
    var description: String { get }
    var id: String { get }
    
    func getAvailableSetsForImport() -> [MPMediaItemCollection]
    func displayNameForCandidateSet(candidateSet: MPMediaItemCollection) -> String
    func nameForItemsOfThisType(count: Int) -> String
    func createPreferenceSet(candidateSet: MPMediaItemCollection) -> PreferenceSet
    
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
    
    func createPreferenceSet(candidateSet: MPMediaItemCollection) -> PreferenceSet {
        return iTunesPlaylistPreferenceSet(candidateItems: candidateSet.items)
    }
    
}