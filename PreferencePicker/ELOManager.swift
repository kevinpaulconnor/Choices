//
//  ELOManager.swift
//  PreferencePicker
//
//  Created by Kevin Connor on 3/16/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import Foundation
import MediaPlayer
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


//ELOManager handles ELO calculations for Preference Sets

class ELOManager {
    let defaultScore = Double(2000)          //Created PreferenceItems start with a score of 2000

    var allTimeComparisons = [Date: Comparison]()
    var recommendedUpcomingComparisons = [(MemoryId, MemoryId)]()
    
    //I wonder whether there's a better way to do this than two structures?
    var keyedPreferenceScores = [MemoryId: PreferenceScore]()
    var preferenceScores = [PreferenceScore]()

    // make upcoming comparisons from set including minimumComparisons for set
    // plus comparison constant. Can improve by floating comparisonConstant
    // based on # in set, or minimumComparisons, or another factor
    var comparisonConstant = 5
    var minimumComparisonsForSet = 0
    var minimumComparisonIds = Set<MemoryId>()

    var latestComparisonInfo = managerFreshComparisonInfo()    
    // store new set-wide comparisons until they are incorporated into scores
    struct managerFreshComparisonInfo {
        var freshScores = [MemoryId : Double]()
        var freshComparisons = [Comparison]()
        var freshIds = Set<MemoryId>()
    }
    
    // reset set-wide comparisons
    fileprivate func refreshManagerFreshComparisonInfo() {
        latestComparisonInfo = managerFreshComparisonInfo()
    }
    
    
    // turn fresh comparisons into scores
    fileprivate func updateRatings() {
        print("updating rankings")
        let kValue = Double(eloKValueForSet())
    
        // calculate for individual PreferenceScores, but do not save yet
        for id in latestComparisonInfo.freshIds {
            let score = keyedPreferenceScores[id]!
            let opponentScores = score.latestComparisonInfo.scoresForFreshOpponents
            let averageOpponentRating = opponentScores.reduce(0) { $0 + $1 } / Double(opponentScores.count)
            let numerator = (score.latestComparisonInfo.points * score.score!)
            let denominator = (averageOpponentRating * Double(opponentScores.count))
            let ratingRatio = numerator / denominator
            //print("id: \(id), opponentScores: \(opponentScores), averageOpponentRating: \(averageOpponentRating), numerator: \(numerator), denominator: \(denominator), ratingRatio: \(ratingRatio)")
            latestComparisonInfo.freshScores[id] = score.score! - (kValue * (0.5 - ratingRatio))
            score.saveAndRefreshComparisonInfo()
            if minimumComparisonIds.contains(id) && score.totalComparisons > minimumComparisonsForSet {
                minimumComparisonIds.remove(id)
            }
        }
        
        /* when finished with all PreferenceScores, save permanently
            and sort preferenceScore array for easy presentation
            seems fragile with id.0 etc.
        */
        for id in latestComparisonInfo.freshScores {
            keyedPreferenceScores[id.0]!.score = id.1
        }
        preferenceScores = keyedPreferenceScores.values.sorted(by: { $0.score > $1.score })
        for pscore in preferenceScores {
            print ("\(pscore.score)")
        }
        //print("\(preferenceScores)")

        saveAndRefreshAfterUpdate()
    }

    //
    fileprivate func saveAndRefreshAfterUpdate() {
        for comparison in latestComparisonInfo.freshComparisons {
            allTimeComparisons[comparison.timestamp] = comparison
        }
        print("total all time comparisons: \(allTimeComparisons.count)")
        refreshManagerFreshComparisonInfo()
        checkMinimumComparisons()
        recommendComparisons()

    }
    
    fileprivate func checkMinimumComparisons() {
        if minimumComparisonIds.isEmpty {
            var newMinimum = Int.max
            for score in preferenceScores {
                if score.totalComparisons < newMinimum {
                    newMinimum = score.totalComparisons
                    minimumComparisonIds = Set<MemoryId>()
                    minimumComparisonIds.insert(score.id!)
                } else if score.totalComparisons == newMinimum {
                    minimumComparisonIds.insert(score.id!)
                }
            }
            minimumComparisonsForSet = newMinimum
            print("new set minimum is: \(minimumComparisonsForSet)")
        }
    }
    
    // determine constant for value of each comparison. Bigger when we have less information
    fileprivate func eloKValueForSet() -> Int {
        switch minimumComparisonsForSet {
        case 50..<Int.max:
            return 32
        case 0..<32:
            return 50
        default: return 50 - (minimumComparisonsForSet - 32)
        }
    }
    
    fileprivate func addScore(_ id: MemoryId, score: Double) -> PreferenceScore {
        let score = PreferenceScore(id: id, score: score)
        keyedPreferenceScores[id] = score
        preferenceScores.append(score)
        return score
    }
    
    fileprivate func recommendComparisons() {
        print("recommending comparisons")
        let comparisonsToStore = preferenceScores.count / 2

        // filter for the PSs with the least comparisons
        var minimumComparisonPreferenceScores = preferenceScores.filter({$0.totalComparisons <= (minimumComparisonsForSet + comparisonConstant)})
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
    fileprivate func updateDecision() -> Bool {
        if latestComparisonInfo.freshComparisons.count > allTimeComparisons.count {
            print("updating")
            return true
        } else {
            return false
        }
    }
    
    fileprivate func createOrUpdatePreferenceScore(_ id: MemoryId, comparison: Comparison, opponentScore: Double, result: MemoryId) {
        var score = keyedPreferenceScores[id]
        if score == nil {
            score = addScore(id, score: defaultScore)
            
        }
        score!.updateLatestComparisonInfo(comparison, opponentScore: opponentScore, result: result)
    }
    
    fileprivate func getScoreForItemId(_ id: MemoryId) -> Double {
        return keyedPreferenceScores[id]!.score!
    }
    
    fileprivate func resetComparisons() {
        recommendedUpcomingComparisons = [(MemoryId, MemoryId)]()
    }

    func getIdsForComparison() -> [MemoryId] {
        let idTuple = recommendedUpcomingComparisons.removeFirst()
        if recommendedUpcomingComparisons.isEmpty {
            recommendComparisons()
        }
        return [idTuple.0, idTuple.1]
    }
    
    func createAndAddComparison(_ id1: MemoryId, id2: MemoryId, result: MemoryId) {
        let comparison = Comparison(id1: id1, id2: id2, result: result, timestamp: nil)
        latestComparisonInfo.freshComparisons.append(comparison)
        latestComparisonInfo.freshIds.insert(id1)
        latestComparisonInfo.freshIds.insert(id2)
        createOrUpdatePreferenceScore(id1, comparison: comparison, opponentScore: getScoreForItemId(id2), result: result)
        createOrUpdatePreferenceScore(id2, comparison: comparison, opponentScore: getScoreForItemId(id1), result: result)
        print("fresh comparison added, total fresh: \(latestComparisonInfo.freshComparisons.count)")
        //print("\(latestComparisonInfo.freshComparisons)")
        if updateDecision() {
            updateRatings()
        }
    }
    
    // on import and from persistence layer
    func initializeComparisons(_ candidateItems: [PreferenceSetItem]) {
        for item in candidateItems {
            // FIXME: on initialization, why does this use a method that returns a score?
            addScore(item.memoryId, score: defaultScore)
        }
        recommendComparisons()
    }
    
    // from persistence layer only
    func restoreComparisons(_ candidateComparisons: [Comparison], candidateScores: [MemoryId: Double]) {
        for comparison in candidateComparisons {
            keyedPreferenceScores[comparison.id1]!.allTimeComparisons[comparison.timestamp] = comparison
            keyedPreferenceScores[comparison.id2]!.allTimeComparisons[comparison.timestamp] = comparison
            allTimeComparisons[comparison.timestamp] = comparison
        }
        
        for score in preferenceScores {
            score.score = candidateScores[score.id!]
            score.totalComparisons = score.allTimeComparisons.count
        }

        resetComparisons()
        checkMinimumComparisons()
        recommendComparisons()
    }
    
    func update() {
        //might need to do other stuff here in the public api
        updateRatings()
    }
    
    func getUpdatedSortedPreferenceScores() -> [(MemoryId, Double)]{
        var ret = [(MemoryId, Double)]()
        for score in preferenceScores {
            ret.append((score.id!, score.score!))
        }
        return ret
    }
    
    func getAllComparisons() -> [Date: Comparison] {
        if latestComparisonInfo.freshComparisons.count > 0 {
            updateRatings()
        }
        return allTimeComparisons
    }
    
    func getAllPreferenceScores() -> [MemoryId: PreferenceScore] {
        if latestComparisonInfo.freshComparisons.count > 0 {
            updateRatings()
        }
        return keyedPreferenceScores
    }
    
    func getPreferenceScoreById(_ id: MemoryId) -> PreferenceScore? {
        if latestComparisonInfo.freshComparisons.count > 0 {
            updateRatings()
        }
        return keyedPreferenceScores[id]
    }
    
}

struct scoreFreshComparisonInfo : Equatable {
    var freshComparisons = [Comparison]()
    var scoresForFreshOpponents = [Double]()
    var points = Double(0)
    var comparisonsSinceScoreUpdate = 0
    
    static func ==(lhs: scoreFreshComparisonInfo, rhs: scoreFreshComparisonInfo) -> Bool {
        return lhs.freshComparisons == rhs.freshComparisons && lhs.scoresForFreshOpponents == rhs.scoresForFreshOpponents && lhs.points == rhs.points && lhs.comparisonsSinceScoreUpdate == rhs.comparisonsSinceScoreUpdate
    }
}

class Comparison : Equatable {
    var id1: MemoryId
    var id2: MemoryId
    var timestamp: Date
    // 0 indicates draw, otherwise the persistent id of the winning item
    var result: MemoryId

    static func ==(lhs: Comparison, rhs: Comparison) -> Bool {
        return lhs.id1 == rhs.id1 && lhs.id2 == rhs.id2 && lhs.timestamp == rhs.timestamp && lhs.result == rhs.result
    }
    
    init(id1: MemoryId, id2: MemoryId, result: MemoryId, timestamp: Date?) {
        self.id1 = id1
        self.id2 = id2
        self.result = result
        self.timestamp = timestamp ?? Date()
    }
    

}

class PreferenceScore {
    var id: MemoryId?
    var score: Double?
    var totalComparisons = 0
    var allTimeComparisons = [Date: Comparison]()
    var latestComparisonInfo = scoreFreshComparisonInfo()
    
    init (id: MemoryId, score: Double) {
        self.id = id
        self.score = score
    }
    
    func updateLatestComparisonInfo(_ comparison: Comparison, opponentScore: Double, result: MemoryId) {
        latestComparisonInfo.comparisonsSinceScoreUpdate += 1
        latestComparisonInfo.freshComparisons.append(comparison)
        latestComparisonInfo.scoresForFreshOpponents.append(opponentScore)
        if result == self.id {
            latestComparisonInfo.points += 1
        } else if result == 0 {
            latestComparisonInfo.points += 0.5
        }
    }
    
    func saveAndRefreshComparisonInfo() {
        totalComparisons += latestComparisonInfo.comparisonsSinceScoreUpdate
        for comparison in latestComparisonInfo.freshComparisons {
            allTimeComparisons[comparison.timestamp] = comparison
        }
        latestComparisonInfo = scoreFreshComparisonInfo()
    }
}
