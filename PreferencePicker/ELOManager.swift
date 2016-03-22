//
//  ELOManager.swift
//  PreferencePicker
//
//  Created by Kevin Connor on 3/16/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import Foundation
import MediaPlayer

//ELOManager handles ELO calculations for Preference Sets

class ELOManager {
    let defaultScore = Double(2000)          //Created PreferenceItems start with a score of 2000
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
    var latestComparisonInfo = managerFreshComparisonInfo()
    
    struct managerFreshComparisonInfo {
        var freshScores = [UInt64 : Double]()
        var freshComparisons = [Comparison]()
        var freshIds = Set<UInt64>()
    }
    
    private func refreshManagerFreshComparisonInfo() {
        latestComparisonInfo = managerFreshComparisonInfo()
    }
    
    private func updateRatings() {
        var kValue = Double(eloKValueForSet())
        for id in latestComparisonInfo.freshIds {
            var score = keyedPreferenceScores[id]!
            let opponentScores = score.latestComparisonInfo.scoresForFreshOpponents
            let averageOpponentRating = opponentScores.reduce(0) { $0 + $1 } / Double(opponentScores.count)
            let numerator = (score.latestComparisonInfo.points * score.score!)
            let denominator = (averageOpponentRating * Double(opponentScores.count))
            let ratingRatio = numerator / denominator
            //print("id: \(id), opponentScores: \(opponentScores), averageOpponentRating: \(averageOpponentRating), numerator: \(numerator), denominator: \(denominator), ratingRatio: \(ratingRatio)")
            latestComparisonInfo.freshScores[id] = score.score! + (kValue * (0.5 - ratingRatio))
        }
        
        let sortedScores = latestComparisonInfo.freshScores.sort({ $0.1 > $1.1 })
        
        for score in sortedScores {
            print("\(score)")
        }

    }
    
    private func eloKValueForSet() -> Int {
        switch minimumComparisonsForSet {
        case 50..<Int.max:
            return 32
        case 0..<32:
            return 50
        default: return 50 - (minimumComparisonsForSet - 32)
        }
    }
    
    private func addScore(id: UInt64, score: Double) -> PreferenceScore {
        let score = PreferenceScore(id: id, score: score)
        keyedPreferenceScores[id] = score
        preferenceScores.append(score)
        return score
    }
    
    private func recommendComparisons() {
        let comparisonsToStore = 40

        // filter for the PSs with the least comparisons
        var minimumComparisonPreferenceScores = preferenceScores.filter({$0.totalComparisons <= (minimumComparisonsForSet + comparisonConstant)})
        while recommendedUpcomingComparisons.count <= comparisonsToStore {
            let firstItem = minimumComparisonPreferenceScores[Int(arc4random_uniform(UInt32(minimumComparisonPreferenceScores.count-1)))]
            var secondItem = firstItem
            while firstItem.id == secondItem.id {
                secondItem = minimumComparisonPreferenceScores[Int(arc4random_uniform(UInt32(minimumComparisonPreferenceScores.count-1)))]
            }
            recommendedUpcomingComparisons.append((firstItem.id!, secondItem.id!))
        }
        //print("recUpComp: \(recommendedUpcomingComparisons)")
        
    }

    /* figure out whether it's time to recalculate scores,
    set upcoming comparisons
    
    */
    private func updateDecision() -> Bool {
        //if latestComparisonInfo.freshComparisons.count > allTimeComparisons.count {
            return true
        //} else {
        //    return false
        //}
    }
    
    private func createOrUpdatePreferenceScore(id: UInt64, comparison: Comparison, opponentScore: Double, result: UInt64) {
        var score = keyedPreferenceScores[id]
        if score == nil {
            score = addScore(id, score: defaultScore)
            
        }
        score!.updateLatestComparisonInfo(comparison, opponentScore: opponentScore, result: result)
    }
    
    func getIdsForComparison() -> [UInt64] {
        let idTuple = recommendedUpcomingComparisons.removeFirst()
        return [idTuple.0, idTuple.1]
    }
    
    func createAndAddComparison(id1: UInt64, id2: UInt64, result: UInt64) {
        updateBeforeRating = true
        let comparison = Comparison(id1: id1, id2: id2, result: result)
        latestComparisonInfo.freshComparisons.append(comparison)
        latestComparisonInfo.freshIds.insert(id1)
        latestComparisonInfo.freshIds.insert(id2)
        createOrUpdatePreferenceScore(id1, comparison: comparison, opponentScore: getScoreForItemId(id2), result: result)
        createOrUpdatePreferenceScore(id2, comparison: comparison, opponentScore: getScoreForItemId(id1), result: result)
        
        //print("\(latestComparisonInfo.freshComparisons)")
        if updateDecision() {
            updateRatings()
        }
    }
    
    // on import, or restoring from persistence
    func initializeComparisons(candidateItems: [MPMediaItem]) {
        for item in candidateItems {
            addScore(item.persistentID, score: defaultScore)
        }
        recommendComparisons()
    }
    
    func getScoreForItemId(id: UInt64) -> Double {
        return keyedPreferenceScores[id]!.score!
    }
    
}

struct scoreFreshComparisonInfo {
    var freshComparisons = [Comparison]()
    var scoresForFreshOpponents = [Double]()
    var points = Double(0)
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
    var latestComparisonInfo = scoreFreshComparisonInfo()
    
    init (id: UInt64, score: Double) {
        self.id = id
        self.score = score
    }
    
    
    func updateLatestComparisonInfo(comparison: Comparison, opponentScore: Double, result: UInt64) {
        latestComparisonInfo.comparisonsSinceScoreUpdate++
        latestComparisonInfo.freshComparisons.append(comparison)
        latestComparisonInfo.scoresForFreshOpponents.append(opponentScore)
        if result == self.id {
            latestComparisonInfo.points += 1
        } else if result == 0 {
            latestComparisonInfo.points += 0.5
        }
    }
    
    func refreshComparisonInfo() {
        latestComparisonInfo = scoreFreshComparisonInfo()
    }
}