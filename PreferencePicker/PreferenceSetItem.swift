//
//  PreferenceSetItem.swift
//  PreferencePicker
//
//  Created by Kevin Connor on 2/25/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import Foundation
import MediaPlayer

protocol PreferenceSetItem {
    var mediaItem: MPMediaItem {get set}
    
    func titleForTableDisplay() -> String
    func subtitleForTableDisplay() -> String
    
}

class iTunesPreferenceSetItem : PreferenceSetItem {
    var mediaItem: MPMediaItem
    
    init(candidateItem: MPMediaItem) {
        self.mediaItem = candidateItem
    }
    
    func titleForTableDisplay() -> String {
        return (self.mediaItem.title ?? "No Title")
    }
    
    func subtitleForTableDisplay() -> String {
        return (self.mediaItem.albumArtist ?? "No Artist")
    }
    
}