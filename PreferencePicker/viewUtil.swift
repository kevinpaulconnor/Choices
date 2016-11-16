//
//  viewUtil.swift
//  PreferencePicker
//
//  Created by Kevin Connor on 4/11/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import UIKit


// storage for view util methods that might be necessary
// globally
struct PreferenceSetTypeColors {
    static func getBGColorForTableCell(_ type: String) -> UIColor {
        var color = UIColor()
        switch type {
        case PreferenceSetTypeIds.iTunesPlaylist:
            color = UIColor(red: 0.9373, green: 0.8353, blue: 0.4549, alpha: 1)
        case PreferenceSetTypeIds.photoMoment:
            color = UIColor(red: 0.6274, green: 0.7490, blue: 0.4431, alpha: 1)
        default: break
        }
        return color
    }
}
