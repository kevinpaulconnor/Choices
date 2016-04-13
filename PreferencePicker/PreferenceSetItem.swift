//
//  PreferenceSetItem.swift
//  PreferencePicker
//
//  Created by Kevin Connor on 2/25/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import Foundation
import MediaPlayer
import Photos

protocol PreferenceSetItem {
    var referenceItem: ReferenceItemContainer {get set}
    var memoryId: Int {get set}
    
    func titleForTableDisplay() -> String
    func subtitleForTableDisplay() -> String
    
}

// pass-through container that enables PreferenceSetItem
// protocol to support different media types
// with the same view and persistence layer code.
// PSI implementations know which variable(s) to fill and use internally
// but that is abstracted from view and persistence layers
class ReferenceItemContainer {
    var mediaItem: MPMediaItem?
    var asset: PHAsset?
}

class iTunesPreferenceSetItem : PreferenceSetItem {
    var referenceItem: ReferenceItemContainer
    var memoryId: MemoryId
    var storageId: MPMediaEntityPersistentID
    var title: String
    var songLength: NSTimeInterval
    
    init(candidateItem: MPMediaItem, set: PreferenceSet) {
        referenceItem = ReferenceItemContainer()
        referenceItem.mediaItem = candidateItem
        storageId = candidateItem.persistentID

        // store data to try to recover if we lost data after a sync
        // (not yet implemented)
        title = (referenceItem.mediaItem!.title ?? "No Title")
        songLength = candidateItem.playbackDuration
        memoryId = set.getNextMemoryId()
    }
    
    func titleForTableDisplay() -> String {
        return (referenceItem.mediaItem!.title ?? "No Title")
    }
    
    func subtitleForTableDisplay() -> String {
        return (referenceItem.mediaItem!.albumArtist ?? "No Artist")
    }
    
}

class photoMomentPreferenceSetItem : PreferenceSetItem {
    var referenceItem: ReferenceItemContainer
    var memoryId: Int
    var storageId: String
    
    init(candidateItem: PHAsset, set: PreferenceSet) {
        referenceItem = ReferenceItemContainer()
        storageId = candidateItem.localIdentifier
        memoryId = set.getNextMemoryId()
    }
    
    // need to think more about how the UI should work for table view images
    // for these title and subtitle methods
    func titleForTableDisplay() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        return (dateFormatter.stringFromDate(referenceItem.asset!.creationDate!) ?? "No Title")
    }
    
    func subtitleForTableDisplay() -> String {
        return ""
    }
    
}