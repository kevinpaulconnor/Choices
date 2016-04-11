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

// pass-through container that enables PreferenceSetType
// protocol to support different PreferenceSetItem types
// with the same view and persistence layer code.
// PST implementations know which variable(s) to fill and use internally
// but that is abstracted from view and persistence layers
class PreferenceSetItemCollection {
    var mpmic: MPMediaItemCollection?
    var mpmi: [MPMediaItem]?
}

protocol PreferenceSetType {
    static var importable: Bool { get }
    static var creatable: Bool { get }
    var description: String { get }
    var id: String { get }
    
    func getAvailableSetsForImport() -> [PreferenceSetItemCollection]
    func displayNameForCandidateSet(candidateSet: PreferenceSetItemCollection) -> String
    func count(candidateSet:PreferenceSetItemCollection) -> Int
    func nameForItemsOfThisType(count: Int) -> String
    func createPreferenceSet(candidateSet: PreferenceSetItemCollection, title: String) -> PreferenceSet
    func createPreferenceItemCollectionFromMOs(managedSet: [PreferenceSetItemMO]) -> PreferenceSetItemCollection
}

class iTunesPreferenceSetType: PreferenceSetType {
    static var importable = true
    static var creatable = false
    var description = "iTunes Playlist"
    var id = PreferenceSetTypeIds.iTunesPlaylist
    
    func getAvailableSetsForImport() -> [PreferenceSetItemCollection] {
        // var albumPredicate: MPMediaPropertyPredicate =
        //MPMediaPropertyPredicate(value: MPMediaType.Music, forProperty: MPMediaItemPropertyMediaType)
        var output = [PreferenceSetItemCollection]()
        for collection in MPMediaQuery.playlistsQuery().collections! {
            var gc = PreferenceSetItemCollection()
            gc.mpmic = collection
        }
        return output
    }
    
    func displayNameForCandidateSet(candidateSet: PreferenceSetItemCollection) -> String {
        let playlist = candidateSet.mpmic as! MPMediaPlaylist
        return playlist.name!
    }
    func count(candidateSet: PreferenceSetItemCollection) -> Int {
        return candidateSet.mpmic!.count
    }

    func nameForItemsOfThisType(count: Int) -> String {
        return (count > 1 ? "songs" : "song")
    }
    
    func createPreferenceSet(candidateSet: PreferenceSetItemCollection, title: String) -> PreferenceSet {
        return iTunesPlaylistPreferenceSet(candidateItems: candidateSet.mpmic!.items, title: title)
    }
    
    func createPreferenceItemCollectionFromMOs(managedSet: [PreferenceSetItemMO]) -> PreferenceSetItemCollection {
            let mediaItemArray = MPMediaQuery.songsQuery().items!
            let collection = PreferenceSetItemCollection()
            collection.mpmi = [MPMediaItem]()
            for mediaItem in mediaItemArray {
                let castedId = NSNumber(unsignedLongLong: mediaItem.persistentID)
                if managedSet.contains({$0.id! == castedId}) {
                    collection.mpmi!.append(mediaItem)
                }
            }
            return collection
    }
    
}