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
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        //self.activeSet = PreferenceSetMO()
        //self.activeItems = self.getAllSavedItems()
        super.init()
        
        guard let modelURL = Bundle.main.url(forResource: "PreferenceSet", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)

        self.managedObjectContext.persistentStoreCoordinator = psc
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let docURL = urls[urls.endIndex-1]
            /* The directory the application uses to store the Core Data store file.
            This code uses a file named "PreferenceSetDataModel.sqlite" in the application's documents directory.
            */
            let storeURL = docURL.appendingPathComponent("PreferenceSetDataModel.sqlite")
            do {
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
    }
    
    fileprivate func fetcher(_ entityName: String, predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?, fetchLimit: Int?) -> [AnyObject] {
        let moc = self.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
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
            let fetched = try moc.fetch(fetchRequest)
            return fetched as [AnyObject]
        } catch {
            fatalError("Failed to fetch \(entityName): \(error)")
        }
    }
    
    func getAllSavedSets () -> [PreferenceSetMO] {
        return self.fetcher("PreferenceSet", predicate: nil, sortDescriptor: nil, fetchLimit: nil) as! [PreferenceSetMO]
    }
    
    fileprivate func getAllSavedPSItems() -> [PreferenceSetItemMO] {
        var existingItems = self.fetcher("PreferenceSetItem", predicate: nil, sortDescriptor: nil, fetchLimit: nil) as! [PreferenceSetItemMO]
        if existingItems.count == 0 {
            existingItems = [PreferenceSetItemMO()]
        }
        return existingItems
    }
    
    fileprivate func getFetchPredicateForPreferenceItem(_ referenceItem: ReferenceItemContainer) -> NSPredicate {
        let potentialStorageIds = referenceItem.storageIds()
        if potentialStorageIds.0 != nil {
            return NSPredicate(format: "id == \(potentialStorageIds.0)")
        } else if potentialStorageIds.1 != nil {
            return NSPredicate(format: "stringId == \(potentialStorageIds.1)")
        }
    }
    
    // might want to return a success/failure condition here eventually
    fileprivate func setStorageIdForPreferenceItemMO(_ item: PreferenceSetItem, managedItem: PreferenceSetItemMO) {
        let potentialStorageIds = item.referenceItem.storageIds()
        if potentialStorageIds.0 != nil {
            managedItem.setValue(NSNumber(value: potentialStorageIds.0! as UInt64), forKey: "id")
        } else if potentialStorageIds.1 != nil {
            managedItem.setValue(potentialStorageIds.1!, forKey: "stringId")
        }
    }
    
    // might be able to simplify fetchPSItem and fetchPSScore to run on common code
    fileprivate func fetchPSItem(_ item: PreferenceSetItem) -> PreferenceSetItemMO? {
        let itemPredicate = getFetchPredicateForPreferenceItem(item.referenceItem)
        let item = self.fetcher("PreferenceSetItem", predicate: itemPredicate, sortDescriptor: nil, fetchLimit: 1) as? [PreferenceSetItemMO]
        
        if item != nil && item!.count > 0 {
            return item![0]
        }
        return nil
    }
    
    fileprivate func fetchPSScore(_ id: UInt64) -> PreferenceScoreMO? {
       // scores are relative to preferenceSet
       let scorePredicate = NSPredicate(format: "%K==%@ AND %K == \(id)", argumentArray:["preferenceSet.title", activeSet!.title!, "preferenceSetItem.id"])
       let score = self.fetcher("PreferenceScore", predicate: scorePredicate, sortDescriptor: nil, fetchLimit: 1) as? [PreferenceScoreMO]
        
        if score != nil && score!.count > 0 {
            return score![0]
        }
        return nil
    }
    
    fileprivate func fetchNewestSavedComparison() -> ComparisonMO? {
        let comparisonPredicate = NSPredicate(format: "%K == %@", "preferenceSet.title", activeSet!.title!)
        let latestDateSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        let comparison = self.fetcher("Comparison", predicate: comparisonPredicate, sortDescriptor: latestDateSortDescriptor, fetchLimit: 1) as? [ComparisonMO]
        if comparison != nil && comparison!.count > 0 {
            return comparison![0]
        }
        return nil
    }
    
    func createSetMO (_ preferenceSet: PreferenceSet) {
        let managedSet = NSEntityDescription.insertNewObject(forEntityName: "PreferenceSet", into: self.managedObjectContext) as! PreferenceSetMO
        managedSet.setValue(preferenceSet.title, forKey: "title")
        managedSet.setValue(preferenceSet.preferenceSetType, forKey: "preferenceSetType")
        
        for item in preferenceSet.getAllItems() {
            var managedItem = self.fetchPSItem(item)
            if managedItem == nil {
                // try recovery stuff here when recovery is implemented
                managedItem = NSEntityDescription.insertNewObject(forEntityName: "PreferenceSetItem", into: self.managedObjectContext) as? PreferenceSetItemMO
                setStorageIdForPreferenceItemMO(item, managedItem: managedItem!)
            }
            
            managedSet.addpreferenceSetItemObject(managedItem!)
            managedItem!.addpreferenceSetObject(managedSet)
        
            let managedScore = NSEntityDescription.insertNewObject(forEntityName: "PreferenceScore", into: self.managedObjectContext) as? PreferenceScoreMO
            managedScore!.setValue(NSNumber(value: preferenceSet.scoreManager.defaultScore as Double), forKey: "score")
            
            managedItem!.addpreferenceScoreObject(managedScore!)
            managedSet.addpreferenceScoreObject(managedScore!)
            managedScore!.setValue(managedItem!, forKey:"preferenceSetItem")
            managedScore!.setValue(managedSet, forKey:"preferenceSet")
        }
        
        self.activeSet = managedSet
    }
 
    func updateActiveSetMO(_ set: PreferenceSetMO) {
        self.activeSet = set
    }
    
    func updateSetMO(_ preferenceSet: PreferenceSet) {
        print("updatingset")
        if activeSet != nil {
            if activeSet!.title == preferenceSet.title {
                // add all new comparisons and relate to activeSet and activeSetItemMOs
                // might want to put this in its own fxn
                let newestSavedComparison = fetchNewestSavedComparison()
                for comparison in preferenceSet.getAllComparisons() {
                    // oof for timeIntervalSince1970. But at least it's human-readable in the if block.
                    if newestSavedComparison == nil || (comparison.0.timeIntervalSince1970 > newestSavedComparison!.timestamp!.timeIntervalSince1970) {
                        let managedComparison = NSEntityDescription.insertNewObject(forEntityName: "Comparison", into: self.managedObjectContext) as! ComparisonMO
                        managedComparison.setValue(comparison.0, forKey: "timestamp")
                        managedComparison.setValue(NSNumber(value: UInt64(comparison.1.result)), forKey: "result")

                        activeSet!.addcomparisonObject(managedComparison)                        
                        let managedItem1 = fetchPSItem(comparison.1.id1 as! PreferenceSetItem)
                        let managedItem2 = fetchPSItem(comparison.1.id2 as! PreferenceSetItem)
                        managedComparison.addpreferenceSetItemObject(managedItem1!)
                        managedComparison.addpreferenceSetItemObject(managedItem2!)
                        managedItem1!.addcomparisonObject(managedComparison)
                        managedItem2!.addcomparisonObject(managedComparison)
                    }
                }
                
                // fetch preferenceScores from preference set and update with latest score
                for score in preferenceSet.getAllPreferenceScores() {
                    let scoreMO = fetchPSScore(UInt64(score.0))
                    scoreMO!.setValue(NSNumber(value: score.1.score!), forKey:"score")
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
}

class PreferenceSetMO: NSManagedObject {
    @NSManaged var title: String?
    @NSManaged var preferenceSetType: String?
    @NSManaged var preferenceSetItem: NSSet?
    @NSManaged var preferenceScore: NSSet?
    @NSManaged var comparison: NSSet?
    
    // makes me nuts that relationships have to begin with lowercase
    // but the model enforces that. I blame objective C.
    @NSManaged func addpreferenceSetItemObject(_ value:PreferenceSetItemMO)
    @NSManaged func addpreferenceScoreObject(_ value: PreferenceScoreMO)
    @NSManaged func addcomparisonObject(_ value: ComparisonMO)
}

class PreferenceSetItemMO: NSManagedObject {
    @NSManaged var id: NSNumber?
    @NSManaged var stringId: String?
    @NSManaged var recoveryProp1: String?
    @NSManaged var recoveryProp2: String?
    
    @NSManaged func addpreferenceSetObject(_ value: PreferenceSetMO)
    @NSManaged func addpreferenceScoreObject(_ value: PreferenceScoreMO)
    @NSManaged func addcomparisonObject(_ value: ComparisonMO)

}

class PreferenceScoreMO: NSManagedObject {
    @NSManaged var score: NSNumber?
    @NSManaged var preferenceSetItem: PreferenceSetItemMO?
    @NSManaged var preferenceSet: PreferenceSetMO?
}

class ComparisonMO: NSManagedObject {
    @NSManaged var result: NSNumber?
    @NSManaged var timestamp: Date?
    @NSManaged var preferenceSetItem: NSSet?
    
    @NSManaged func addpreferenceSetObject(_ value: PreferenceSetMO)
    @NSManaged func addpreferenceSetItemObject(_ value:PreferenceSetItemMO)

}
