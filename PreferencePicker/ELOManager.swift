//
//  ELOManager.swift
//  PreferencePicker
//
//  Created by Kevin Connor on 3/16/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import Foundation

//ELOManager handles ELO calculations for Preference Sets

class ELOManager {
    let defaultScore = 2000          //Created PreferenceItems start with a score of 2000
    let thousandthsMultiplier = 0.7 // each thousandth of a point of difference in actual results
                                    // above or below .5 adjust rating by .7 rating points
                                    // up or down
    var allTimeComparisons = [NSDate: Comparison]()
    var recommendedUpcomingComparisons = [(UInt64, UInt64)]()
    
    //I wonder whether there's a better way to do this than two structures?
    var keyedPreferenceScores = [UInt64: PreferenceScore]()
    var preferenceScores = [PreferenceScore]()

    // make upcoming comparisons from set including minimumComparisons for set
    // plus comparison constant. Can improve by floating comparisonConstant
    // based on # in set, or minimumComparisons, or another factor
    var comparisonConstant = 5
    var minimumComparisonsForSet = 0
    var updateBeforeRating = false
    var latestComparisonInfo = freshComparisonInfo()
    
    private func updateRatings() {
        
        for comparison in freshComparisons {
            
        }

    }
    
    private func addScore(id: UInt64) -> PreferenceScore {
        let score = PreferenceScore()
        keyedPreferenceScores[id] = score
        preferenceScores.append(score)
        return score
    }
    
    private func recommendComparisons() {
        let comparisonsToStore = 40

        // filter for the PSs with the least comparisons
        var minimumComparisonPreferenceScores = preferenceScores.filter({$0.totalComparisons == (minimumComparisonsForSet + comparisonConstant)})
        while recommendedUpcomingComparisons.count <= comparisonsToStore {
            let firstItem = minimumComparisonPreferenceScores[Int(arc4random_uniform(UInt32(minimumComparisonPreferenceScores.count)))]
            var secondItem = firstItem
            while firstItem.id == secondItem.id {
                secondItem = minimumComparisonPreferenceScores[Int(arc4random_uniform(UInt32(minimumComparisonPreferenceScores.count)))]
            }
            recommendedUpcomingComparisons.append((firstItem.id!, secondItem.id!))
        }
        
    }

    /* figure out whether it's time to recalculate scores,
    set upcoming comparisons
    
    */
    private func updateDecision() -> Bool {
        if latestComparisonInfo.freshComparisons.count > allTimeComparisons.count {
            return true
        } else {
            return false
        }
    }
    
    private func createOrUpdatePreferenceScore(id: UInt64, comparison: Comparison, opponentScore: Double) {
        var score = keyedPreferenceScores[id]
        if score == nil {
            score = addScore(id)
            
        }
        score!.updateLatestComparisonInfo(comparison, opponentScore)
    }
    
    func getIdsForComparison() -> [UInt64] {
        let idTuple = recommendedUpcomingComparisons.removeFirst()
        return [idTuple.0, idTuple.1]
    }
    
    func createAndAddComparison(id1: UInt64, id2: UInt64, result: UInt64) {
        updateBeforeRating = true
        let comparison = Comparison(id1: id1, id2: id2, result: result)
        latestComparisonInfo.freshComparisons.append(comparison)
        createOrUpdatePreferenceScore(id1, comparison: comparison, opponentScore: getScoreForItemId(id2))
        createOrUpdatePreferenceScore(id2, comparison: comparison, opponentScore: getScoreForItemId(id1))
        
        print("\(latestComparisonInfo.freshComparisons)")
        if updateDecision() {
            updateRatings()
        }
    }
    
    // on import, or restoring from persistence
    func initializeComparisons() {
    
        recommendComparisons()
    }
    
    func getScoreForItemId(id: UInt64) -> Double {
        return keyedPreferenceScores[id]!.score!
    }
    
}

struct freshComparisonInfo {
    var freshComparisons = [Comparison]()
    var scoresForFreshOpponents = [Double]()
    var comparisonsSinceScoreUpdate = 0
}

class Comparison {
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

class PreferenceScore {
    var id: UInt64?
    var score: Double?
    var totalComparisons = 0
    var allTimeComparisons = [NSDate: Comparison]()
    var latestComparisonInfo = freshComparisonInfo()
    
    func updateLatestComparisonInfo(comparison: Comparison, opponentScore: Double) {
        latestComparisonInfo.comparisonsSinceScoreUpdate++
        latestComparisonInfo.freshComparisons.append(comparison)
        latestComparisonInfo.scoresForFreshOpponents.append(opponentScore)
    }
    
    func refreshComparisonInfo() {
        latestComparisonInfo = freshComparisonInfo()
    }
}