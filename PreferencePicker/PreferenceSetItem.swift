//
//  PreferenceSetItem.swift
//  PreferencePicker
//
//  Created by Kevin Connor on 2/25/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import Foundation
import MediaPlayer

// will probably need to reorganize this structure for created items
protocol PreferenceSetItem {
    var mediaItem: MPMediaItem {get set}
    
    func titleForTableDisplay() -> String
    func subtitleForTableDisplay() -> String
    
}

class iTunesPreferenceSetItem : PreferenceSetItem {
    var mediaItem: MPMediaItem
    var id: MPMediaEntityPersistentID
    var title: String
    var songLength: NSTimeInterval
    
    init(candidateItem: MPMediaItem) {
        self.mediaItem = candidateItem
        self.id = candidateItem.persistentID

        // store data to try to recover if we lost data after a sync
        self.title = (self.mediaItem.title ?? "No Title")
        self.songLength = candidateItem.playbackDuration
    }
    
    func titleForTableDisplay() -> String {
        return (self.mediaItem.title ?? "No Title")
    }
    
    func subtitleForTableDisplay() -> String {
        return (self.mediaItem.albumArtist ?? "No Artist")
    }
    
}