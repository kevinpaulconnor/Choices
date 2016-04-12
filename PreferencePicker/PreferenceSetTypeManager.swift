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
import Photos

class PreferenceSetTypeManager {
    static let types = [
        PreferenceSetTypeIds.iTunesPlaylist: iTunesPreferenceSetType(),
        PreferenceSetTypeIds.photoMoment: photoPreferenceSetType()
    ]
    
    static func allPreferenceSetTypes() -> [PreferenceSetType] {
        var typeArray = [PreferenceSetType]()
        for type in types {
            typeArray.append(type.value as! PreferenceSetType)
        }
        return typeArray
    }
    
    static func getSetType(psId: String) -> PreferenceSetType {
       return types[psId] as! PreferenceSetType
    }
    
}

struct PreferenceSetTypeIds {
    static let iTunesPlaylist = "iTunesPlayList"
    static let photoMoment = "photoMoment"
}

// pass-through container that enables PreferenceSetType
// protocol to support different PreferenceSetItem types
// with the same view and persistence layer code.
// PST implementations know which variable(s) to fill and use internally
// but that is abstracted from view and persistence layers
class PreferenceSetItemCollection {
    var mpmic: MPMediaItemCollection?
    var mpmi: [MPMediaItem]?
    var phcl: PHCollectionList?
}

protocol PreferenceSetType {
    static var importable: Bool { get }
    static var creatable: Bool { get }
    var description: String { get }
    var id: String { get }
    
    func getAvailableSetsForImport() -> [PreferenceSetItemCollection]
    func displayNameForCandidateSet(candidateSet: PreferenceSetItemCollection) -> String
    func itemDetailForDisplay(candidateSet:PreferenceSetItemCollection) -> String
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
      var output = [PreferenceSetItemCollection]()
        for collection in MPMediaQuery.playlistsQuery().collections! {
            let gc = PreferenceSetItemCollection()
            gc.mpmic = collection
            output.append(gc)
        }
        return output
    }
    
    func displayNameForCandidateSet(candidateSet: PreferenceSetItemCollection) -> String {
        let playlist = candidateSet.mpmic as! MPMediaPlaylist
        return playlist.name!
    }
    func itemDetailForDisplay(candidateSet: PreferenceSetItemCollection) -> String {
        let count = candidateSet.mpmic!.count
        return "\(count) \(self.nameForItemsOfThisType(count))"
    }

    func nameForItemsOfThisType(count: Int) -> String {
        return (count > 1 ? "songs" : "song")
    }
    
    func createPreferenceSet(candidateSet: PreferenceSetItemCollection, title: String) -> PreferenceSet {
        var items: [MPMediaItem]
        if candidateSet.mpmic != nil {
            items = candidateSet.mpmic!.items
        } else {
            items = candidateSet.mpmi!
        }
        
        return iTunesPlaylistPreferenceSet(candidateItems: items, title: title)
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

class photoPreferenceSetType: PreferenceSetType {
    static var importable = true
    static var creatable = false
    var description = "Photo Moments"
    var id = PreferenceSetTypeIds.photoMoment
    
    func getAvailableSetsForImport() -> [PreferenceSetItemCollection] {
        var output = [PreferenceSetItemCollection]()
        
        // this is not the world's finest api, Apple
        let request = PHCollectionList.fetchMomentListsWithSubtype(PHCollectionListSubtype.MomentListCluster, options: nil)
        print("\(request.count)")
        request.enumerateObjectsUsingBlock{(object: AnyObject!,
            count: Int,
            stop: UnsafeMutablePointer<ObjCBool>) in
            //print("\(object.typeIdentifier)")
            //if object is PHAssetCollection {
                let collection = object as! PHCollectionList
                print("\(collection.localizedTitle)")
                let gc = PreferenceSetItemCollection()
                gc.phcl = collection
                output.append(gc)
            //}
        }
        return output
    }
    
    func displayNameForCandidateSet(candidateSet: PreferenceSetItemCollection) -> String {
        return candidateSet.phcl!.localizedTitle ?? "(No Title Available)"
    }
    
    func itemDetailForDisplay(candidateSet: PreferenceSetItemCollection) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        return ("\(dateFormatter.stringFromDate(candidateSet.phcl!.startDate!)) - \(dateFormatter.stringFromDate(candidateSet.phcl!.endDate!))")
    }
    
    func nameForItemsOfThisType(count: Int) -> String {
        return (count > 1 ? "photos" : "photo")
    }
    
    func createPreferenceSet(candidateSet: PreferenceSetItemCollection, title: String) -> PreferenceSet {
        return iTunesPlaylistPreferenceSet(candidateItems: [MPMediaItem](), title: "title")
    }
    
    func createPreferenceItemCollectionFromMOs(managedSet: [PreferenceSetItemMO]) -> PreferenceSetItemCollection {
        return PreferenceSetItemCollection()
    }
}