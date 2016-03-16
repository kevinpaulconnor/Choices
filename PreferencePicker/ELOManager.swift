//
//  ELOManager.swift
//  PreferencePicker
//
//  Created by Kevin Connor on 3/16/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import Foundation

//ELOManager handles ELO calculations for

class ELOManager {
    let defaultScore = 2000          //Created PreferenceItems start with a score of 2000
    let thousandthsMultiplier = 0.7 // each thousandth of a point of difference in actual results
                                    // above or below .5 adjust rating by .7 rating points
                                    // up or down
}