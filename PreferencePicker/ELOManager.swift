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
    var comparisons = [NSDate: Comparison]()
    var recommendedUpcomingComparisons = [(UInt64, UInt64)]()
    var sortedPreferenceScores = [PreferenceScore]()
    
    func updateRatings() {
        
    }

    func createAndAddComparison(id1: UInt64, id2: UInt64, result: UInt64) {
        let comparison = Comparison(id1: id1, id2: id2, result: result)
        comparisons[comparison.timestamp] = comparison
        if self.updateDecision() {
            
        }
    }
    
    func initializeComparisons() {
    
    }
    
    /* figure out whether it's time to recalculate scores,
        set upcoming comparisons
    
    */
    private func updateDecision() -> Bool {
        return false
    }
    
}

struct Comparison {
    var id1: UInt64
    var id2: UInt64
    var timestamp: NSDate
    // 0 indicates draw, otherwise the persistent id of the winning item
    var result: UInt64
    
    init(id1: UInt64, id2: UInt64, result: UInt64) {
        self.id1 = id1
        self.id2 = id2
        self.result = result
        self.timestamp = NSDate()
    }
}

struct PreferenceScore {
    var id: UInt64
    var score: Double
    var comparisonsSinceScoreUpdate = 0
    var comparisons = [NSDate: Comparison]()
}