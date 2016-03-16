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
    
    private func fetcher(entityName: String, predicate: NSPredicate?) -> [AnyObject] {
        let moc = self.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: entityName)
        if predicate != nil {
            fetchRequest.predicate = predicate!
        }
        do {
            let fetched = try moc.executeFetchRequest(fetchRequest)
            return fetched
        } catch {
            fatalError("Failed to fetch \(entityName): \(error)")
        }
    }
    
    func getAllSavedSets () -> [PreferenceSetMO] {
        return self.fetcher("PreferenceSet", predicate: nil) as! [PreferenceSetMO]
    }
    
    private func getAllSavedPSItems() -> [PreferenceSetItemMO] {
        var existingItems = self.fetcher("PreferenceSetItem", predicate: nil) as! [PreferenceSetItemMO]
        if existingItems.count == 0 {
            existingItems = [PreferenceSetItemMO()]
        }
        return existingItems
    }
    
    private func fetchPSItem(id: Int64) -> PreferenceSetItemMO? {
        let itemPredicate = NSPredicate(format: "id == \(id)")
        // checking only [0] probably isn't really going to work always
        // since uniqueness isn't enforced. but when it doesn't work it will indicate
        // a bigger problem
        let item = self.fetcher("PreferenceSetItem", predicate: itemPredicate) as? [PreferenceSetItemMO]
        
        if item != nil && item!.count > 0 {
            return item![0]
        }
        return nil
    }
    
    func createSetMO (preferenceSet: PreferenceSet) {
        let managedSet = NSEntityDescription.insertNewObjectForEntityForName("PreferenceSet", inManagedObjectContext: self.managedObjectContext) as! PreferenceSetMO
        managedSet.setValue(preferenceSet.title, forKey: "title")
        managedSet.setValue(preferenceSet.preferenceSetType, forKey: "preferenceSetType")
        
        for item in preferenceSet.getAllItems() {
            let setItemId = Int64(item.mediaItem.persistentID)
            var managedItem = self.fetchPSItem(setItemId)
            if managedItem == nil {
                // try recovery stuff here when recovery is implemented
                managedItem = NSEntityDescription.insertNewObjectForEntityForName("PreferenceSetItem", inManagedObjectContext: self.managedObjectContext) as? PreferenceSetItemMO
                managedItem!.setValue(NSNumber(unsignedLongLong: item.mediaItem.persistentID), forKey: "id")
            }
            
            managedSet.addpreferenceSetItemObject(managedItem!)
            managedItem!.addpreferenceSetObject(managedSet)
            
            let managedScore = NSEntityDescription.insertNewObjectForEntityForName("PreferenceScore", inManagedObjectContext: self.managedObjectContext) as? PreferenceScoreMO
            managedScore!.addpreferenceSetItemObject(managedItem!)
            managedScore!.addscoreForSetObject(managedSet)
            
            managedItem!.addpreferenceScoreObject(managedScore!)
            managedSet.addpreferenceScoreObject(managedScore!)
        }
        
        self.activeSet = managedSet
    }
    
    func save () {
        do {
            try self.managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func update(preferenceSet: PreferenceSet) {
        
    }
    
    func load(name: String, type: PreferenceSetType) -> PreferenceSet {

        return type.createPreferenceSet([MPMediaItem()], title: "Test")
    }
    
}

class PreferenceSetMO: NSManagedObject {
    @NSManaged var title: String?
    @NSManaged var preferenceSetType: String?
    @NSManaged var preferenceSetItem: NSSet?
    
    // makes me nuts that relationships have to begin with lowercase
    // but the model enforces that. I blame objective C.
    @NSManaged func addpreferenceSetItemObject(value:PreferenceSetItemMO)
    @NSManaged func addpreferenceScoreObject(value: PreferenceScoreMO)
    @NSManaged func addcomparisonObject(value: ComparisonMO)
}

class PreferenceSetItemMO: NSManagedObject {
    @NSManaged var id: NSNumber?
    @NSManaged var preferenceSet: NSSet?
    
    @NSManaged func addpreferenceSetObject(value: PreferenceSetMO)
    @NSManaged func addpreferenceScoreObject(value: PreferenceScoreMO)
    @NSManaged func addcomparisonObject(value: ComparisonMO)
    @NSManaged var recoveryProp1: String?
    @NSManaged var recoveryProp2: String?
}

class PreferenceScoreMO: NSManagedObject {
    @NSManaged var score: NSNumber?

    // but the model enforces that. I blame objective C.
    @NSManaged func addpreferenceSetItemObject(value:PreferenceSetItemMO)
    @NSManaged func addscoreForSetObject(value:PreferenceSetMO)
}

class ComparisonMO: NSManagedObject {
    @NSManaged var result: NSNumber?
    
    @NSManaged func addpreferenceSetObject(value: PreferenceSetMO)
    @NSManaged func addpreferenceSetItemObject(value:PreferenceSetItemMO)

}