//
//  PreferenceSetDataController.swift
//  PreferencePicker
//
//  Created by Kevin Connor on 3/9/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import Foundation
import CoreData
import MediaPlayer

class PreferenceSetDataController : NSObject {
    var managedObjectContext: NSManagedObjectContext
    
    // store 
    var activeSet: PreferenceSetMO?
    var activeItems: [Int: PreferenceSetItemMO]?
    
    override init() {
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        //self.activeSet = PreferenceSetMO()
        //self.activeItems = self.getAllSavedItems()
        super.init()
        
        guard let modelURL = NSBundle.mainBundle().URLForResource("PreferenceSet", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)

        self.managedObjectContext.persistentStoreCoordinator = psc
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let docURL = urls[urls.endIndex-1]
            /* The directory the application uses to store the Core Data store file.
            This code uses a file named "PreferenceSetDataModel.sqlite" in the application's documents directory.
            */
            let storeURL = docURL.URLByAppendingPathComponent("PreferenceSetDataModel.sqlite")
            do {
                try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
    }
    
    private func fetcher(entityName: String, predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?, fetchLimit: Int?) -> [AnyObject] {
        let moc = self.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: entityName)
        if predicate != nil {
            fetchRequest.predicate = predicate!
        }
        if sortDescriptor != nil {
            fetchRequest.sortDescriptors = [sortDescriptor!]
        }
        if fetchLimit != nil {
            fetchRequest.fetchLimit = fetchLimit!
        }
        do {
            let fetched = try moc.executeFetchRequest(fetchRequest)
            return fetched
        } catch {
            fatalError("Failed to fetch \(entityName): \(error)")
        }
    }
    
    func getAllSavedSets () -> [PreferenceSetMO] {
        return self.fetcher("PreferenceSet", predicate: nil, sortDescriptor: nil, fetchLimit: nil) as! [PreferenceSetMO]
    }
    
    private func getAllSavedPSItems() -> [PreferenceSetItemMO] {
        var existingItems = self.fetcher("PreferenceSetItem", predicate: nil, sortDescriptor: nil, fetchLimit: nil) as! [PreferenceSetItemMO]
        if existingItems.count == 0 {
            existingItems = [PreferenceSetItemMO()]
        }
        return existingItems
    }
    
    // might be able to simplify fetchPSItem and fetchPSScore to run on common code
    private func fetchPSItem(id: UInt64) -> PreferenceSetItemMO? {
        let itemPredicate = NSPredicate(format: "id == \(id)")
        let item = self.fetcher("PreferenceSetItem", predicate: itemPredicate, sortDescriptor: nil, fetchLimit: 1) as? [PreferenceSetItemMO]
        
        if item != nil && item!.count > 0 {
            return item![0]
        }
        return nil
    }
    
    private func fetchPSScore(id: UInt64) -> PreferenceScoreMO? {
        // scores are relative to preferenceSet
        let scorePredicate = NSPredicate(format: "%K==%@ AND %K == %@", "preferenceSet.title", activeSet!.title!, "preferenceSetItem.id", id)
        //NSPredicate(format: "%K == %@ AND %K == %@", argumentArray:["key1", "value1", "key2", "value2"])
        let score = self.fetcher("PreferenceScore", predicate: scorePredicate, sortDescriptor: nil, fetchLimit: 1) as? [PreferenceScoreMO]
        
        if score != nil && score!.count > 0 {
            return score![0]
        }
        return nil
    }
    
    private func fetchNewestSavedComparison() -> ComparisonMO? {
        let comparisonPredicate = NSPredicate(format: "%K == %@", "preferenceSet.title", activeSet!.title!)
        let latestDateSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let comparison = self.fetcher("Comparison", predicate: comparisonPredicate, sortDescriptor: latestDateSortDescriptor, fetchLimit: 1) as? [ComparisonMO]
        if comparison != nil {
            return comparison![0]
        }
        return nil
    }
    
    func createSetMO (preferenceSet: PreferenceSet) {
        let managedSet = NSEntityDescription.insertNewObjectForEntityForName("PreferenceSet", inManagedObjectContext: self.managedObjectContext) as! PreferenceSetMO
        managedSet.setValue(preferenceSet.title, forKey: "title")
        managedSet.setValue(preferenceSet.preferenceSetType, forKey: "preferenceSetType")
        
        for item in preferenceSet.getAllItems() {
            item.mediaItem.persistentID
            var managedItem = self.fetchPSItem(item.mediaItem.persistentID)
            if managedItem == nil {
                // try recovery stuff here when recovery is implemented
                managedItem = NSEntityDescription.insertNewObjectForEntityForName("PreferenceSetItem", inManagedObjectContext: self.managedObjectContext) as? PreferenceSetItemMO
                managedItem!.setValue(NSNumber(unsignedLongLong: item.mediaItem.persistentID), forKey: "id")
            }
            
            managedSet.addpreferenceSetItemObject(managedItem!)
            managedItem!.addpreferenceSetObject(managedSet)
        
            let managedScore = NSEntityDescription.insertNewObjectForEntityForName("PreferenceScore", inManagedObjectContext: self.managedObjectContext) as? PreferenceScoreMO
            managedScore!.setValue(NSNumber(double: preferenceSet.scoreManager.defaultScore), forKey: "score")
            
            managedItem!.addpreferenceScoreObject(managedScore!)
            managedSet.addpreferenceScoreObject(managedScore!)
            managedScore!.setValue(managedItem!, forKey:"preferenceSetItem")
            managedScore!.setValue(managedSet, forKey:"preferenceSet")
        }
        
        self.activeSet = managedSet
    }
 
    
    func updateSetMO(preferenceSet: PreferenceSet) {
        if activeSet != nil {
            if activeSet!.title == preferenceSet.title {
                // add all new comparisons and relate to activeSet and activeSetItemMOs
                // might want to put this in its own fxn
                let newestSavedComparison = fetchNewestSavedComparison()
                for comparison in preferenceSet.getAllComparisons() {
                    // oof for timeIntervalSince1970. But at least it's human-readable in the if block.
                    if newestSavedComparison == nil || comparison.0.timeIntervalSince1970 > newestSavedComparison!.timestamp!.timeIntervalSince1970 {
                        let managedComparison = NSEntityDescription.insertNewObjectForEntityForName("Comparison", inManagedObjectContext: self.managedObjectContext) as! ComparisonMO
                        managedComparison.setValue(comparison.0, forKey: "timestamp")
                        managedComparison.setValue(comparison.1, forKey: "result")
                        
                        managedComparison.addpreferenceSetObject(activeSet!)
                        activeSet!.addcomparisonObject(managedComparison)
                        
                        let managedItem1 = fetchPSItem(comparison.1.id1)
                        let managedItem2 = fetchPSItem(comparison.1.id2)
                        managedComparison.addpreferenceSetItemObject(managedItem1!)
                        managedComparison.addpreferenceSetItemObject(managedItem2!)
                        managedItem1!.addcomparisonObject(managedComparison)
                        managedItem2!.addcomparisonObject(managedComparison)
                    }
                }
                
                // fetch preferenceScores from preference set and update with latest score
                for score in preferenceSet.getAllPreferenceScores() {
                    let scoreMO = fetchPSScore(score.0)
                    scoreMO!.setValue(NSNumber(double: score.1.score!), forKey:"score")
                }
            } else {
                //throw some kind of error
            }
        } else {
            // throw some kind of error
        }
    }
    
    
    func save () {
        do {
            try self.managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func load(name: String, type: PreferenceSetType) -> PreferenceSet {

        return type.createPreferenceSet([MPMediaItem()], title: "Test")
    }
    
}

class PreferenceSetMO: NSManagedObject {
    @NSManaged var title: String?
    @NSManaged var preferenceSetType: String?
    @NSManaged var preferenceSetItem: NSSet?
    @NSManaged var preferenceScore: NSSet?
    
    // makes me nuts that relationships have to begin with lowercase
    // but the model enforces that. I blame objective C.
    @NSManaged func addpreferenceSetItemObject(value:PreferenceSetItemMO)
    @NSManaged func addpreferenceScoreObject(value: PreferenceScoreMO)
    @NSManaged func addcomparisonObject(value: ComparisonMO)
}

class PreferenceSetItemMO: NSManagedObject {
    @NSManaged var id: NSNumber?
    @NSManaged var recoveryProp1: String?
    @NSManaged var recoveryProp2: String?
    
    @NSManaged func addpreferenceSetObject(value: PreferenceSetMO)
    @NSManaged func addpreferenceScoreObject(value: PreferenceScoreMO)
    @NSManaged func addcomparisonObject(value: ComparisonMO)

}

class PreferenceScoreMO: NSManagedObject {
    @NSManaged var score: NSNumber?
    @NSManaged var preferenceSetItem: PreferenceSetItemMO?
    @NSManaged var preferenceSet: PreferenceSetMO?
}

class ComparisonMO: NSManagedObject {
    @NSManaged var result: NSNumber?
    @NSManaged var timestamp: NSDate?
    
    @NSManaged func addpreferenceSetObject(value: PreferenceSetMO)
    @NSManaged func addpreferenceSetItemObject(value:PreferenceSetItemMO)

}