//
//  ELOManagerTests.swift
//  PreferencePicker
//
//  Created by Kevin Connor on 11/16/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import XCTest
@testable import PreferencePicker

class ELOManagerTests: XCTestCase {
    var manager: ELOManager!
    
    // This isn't the best place for this definition in the medium term
    class preferenceSetItemForTests : PreferenceSetItem {
        var referenceItem: ReferenceItemContainer
        var memoryId: MemoryId
        
        init(id: MemoryId) {
            self.memoryId = id
            self.referenceItem = ReferenceItemContainer()
        }
        
        func titleForTableDisplay() -> String {
            return "title"
        }
        
        func subtitleForTableDisplay() -> String {
            return "subtitle"
        }
    }
    
    override func setUp() {
        super.setUp()
        manager = ELOManager();
      
    }
    
    override func tearDown() {
        super.tearDown()
        manager = nil;
    }
    
    /*func initializeComparisons(items: [preferenceSetItemForTests]) {
        let items =
        manager.initializeComparisons(items)
    }*/
    
    func testInitializeComparisons() {
        //should throw error at preferencesetitem creation time
        //saving this commented out for when i write those tests
        //XCTAssertThrowsError(manager.initializeComparisons([preferenceSetItemForTests(id: -1), preferenceSetItemForTests(id:2)]))
        
        manager.initializeComparisons([preferenceSetItemForTests(id: 1), preferenceSetItemForTests(id:2)])
        // all scores should be initialized to the manager default score
        for item in manager.getAllPreferenceScores() {
            XCTAssertEqual(item.value.score, manager.defaultScore)
        }
        
        //recommendComparisons should run and fill upcoming comparisons,
        //to half of the # of preference scores in the set + 1
        XCTAssertEqual(manager.recommendedUpcomingComparisons.count, ((manager.preferenceScores.count / 2)+1))
    }
    
    func testGetIdsForComparison() {
        manager.initializeComparisons([preferenceSetItemForTests(id: 1), preferenceSetItemForTests(id:2)])
        let memoryIdArray = [1, 2]
        var result = manager.getIdsForComparison()
        
        // initialized with memoryIds 1 and 2, getIdsForComparison() should return [1,2] or [2,1]
        result.sort()
        XCTAssertEqual(memoryIdArray, result)
    }
    
    func testCreateComparisons() {
        let comparison1 = Comparison(id1: 1, id2: 2, result: 1, timestamp: nil)
        //check that usual case is created correctly
        XCTAssertEqual(comparison1.id1, 1)
        XCTAssertEqual(comparison1.id2, 2)
        XCTAssertEqual(comparison1.result, 1)
        //comparison should timestamp with the current date if none is passed in
        XCTAssertNotNil(comparison1.timestamp)
        
        //input validation
        XCTAssertThrowsError(Comparison(id1: -1, id2: 2, result: 1, timestamp: nil))
        XCTAssertThrowsError(Comparison(id1: 1, id2: -2, result: 1, timestamp: nil))
        XCTAssertThrowsError(Comparison(id1: 1, id2: 2, result: -1, timestamp: nil))
        // results that don't match id1 or id2 or 0 should be thrown out
        XCTAssertThrowsError(Comparison(id1: 1, id2: 2, result: 5, timestamp: nil))

    }
    
    func testCreatePreferenceScore() {
        let score = PreferenceScore(id:1, score: 2000)
        // check correct default initialization
        XCTAssertEqual(score.id,1)
        XCTAssertEqual(score.score,2000)
        XCTAssertEqual(score.totalComparisons,0)
        XCTAssertTrue(score.allTimeComparisons == [Date: Comparison]())
        XCTAssertEqual(score.latestComparisonInfo, scoreFreshComparisonInfo())
        
        // input validation
        XCTAssertThrowsError(PreferenceScore(id:-1, score: 2000))
        XCTAssertThrowsError(PreferenceScore(id:0, score: 2000))
        XCTAssertThrowsError(PreferenceScore(id:1, score: 0))
        XCTAssertThrowsError(PreferenceScore(id:1, score: -2000))
    }
    
    func testPreferenceScoreUpdateLatestComparisonInfo() {
        let score = PreferenceScore(id:1, score:2000)
        let comparison = Comparison(id1: 1, id2: 2, result: 1, timestamp: nil)
        score.updateLatestComparisonInfo(comparison, opponentScore: 2000, result: 1)
        XCTAssertEqual(score.latestComparisonInfo.comparisonsSinceScoreUpdate, 1)
        XCTAssertEqual(score.latestComparisonInfo.freshComparisons, [comparison])
        XCTAssertEqual(score.latestComparisonInfo.scoresForFreshOpponents, [2000])
        XCTAssertEqual(score.latestComparisonInfo.points, 1)
        
        let comparison1 = Comparison(id1: 1, id2: 2, result: 0, timestamp: nil)
        score.updateLatestComparisonInfo(comparison1, opponentScore: 2000, result: 0)
        XCTAssertEqual(score.latestComparisonInfo.comparisonsSinceScoreUpdate, 2)
        XCTAssertEqual(score.latestComparisonInfo.freshComparisons, [comparison, comparison1])
        XCTAssertEqual(score.latestComparisonInfo.scoresForFreshOpponents, [2000, 2000])
        XCTAssertEqual(score.latestComparisonInfo.points, 1.5)
        
        score.saveAndRefreshComparisonInfo()
        XCTAssertEqual(score.totalComparisons, 2)
        XCTAssertEqual(score.allTimeComparisons[comparison.timestamp], comparison)
        XCTAssertEqual(score.allTimeComparisons[comparison1.timestamp], comparison1)
        XCTAssertEqual(score.latestComparisonInfo, scoreFreshComparisonInfo())
        
    }
    
    func testCreateAndAddComparison() {
        manager.initializeComparisons([preferenceSetItemForTests(id: 1), preferenceSetItemForTests(id:2)])
        manager.createAndAddComparison(1, id2: 2, result: 1)
        let score = manager.keyedPreferenceScores[1]
        // with one comparison added, ratings should update and latestComparisonInfo should be wiped clean
        // for both the manager and the PreferenceScore
        XCTAssertEqual(manager.latestComparisonInfo.freshComparisons.count, 0)
        XCTAssertEqual(score?.latestComparisonInfo.freshComparisons.count, 0)
        
        manager.createAndAddComparison(1, id2: 2, result: 1)
        // with an additional comparison, ratings should not update
        XCTAssertEqual(manager.latestComparisonInfo.freshComparisons.count, 1)
        let testSet = Set<MemoryId>([1,2])
        XCTAssertEqual(testSet, manager.latestComparisonInfo.freshIds)
        
    }
    
    func testRestoreComparisons() {
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
