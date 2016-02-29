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

    func titleForTableDisplay() -> String
    func subtitleForTableDisplay() -> String
    
}

class iTunesPreferenceSetItem : PreferenceSetItem {
    
    init(candidateItem: MPMediaItem) {
        
    }
    
    func titleForTableDisplay() -> String {
        return  "title"
    }
    
    func subtitleForTableDisplay() -> String {
        return  "subtitle"
    }
    
}