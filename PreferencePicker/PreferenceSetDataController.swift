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
    
    override init() {
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
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
    
    func getAllSavedSetNames () -> [minimalSetReference] {
        
        return [minimalSetReference(title: "Name", preferenceSetType: iTunesPreferenceSetType())]
    }
    
    func save (preferenceSet: PreferenceSet) {
        let managedSet = NSEntityDescription.insertNewObjectForEntityForName(preferenceSet.title, inManagedObjectContext: self.managedObjectContext) as! PreferenceSetMO
        
        do {
            try self.managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func update(preferenceSet: PreferenceSet) {
        
    }
    
    func load(name: String, type: PreferenceSetType) -> PreferenceSet {

        return type.createPreferenceSet(MPMediaItemCollection(), title: "Test")
    }
    
    class PreferenceSetMO: NSManagedObject {
        @NSManaged var title: String?
        @NSManaged var preferenceSetType: String?
    }
}