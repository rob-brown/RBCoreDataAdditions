//
//  RBCoreDataManager.h
//
//  Created by Robert Brown on 7/8/11.
//  Copyright 2011 Robert Brown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "RBSingleton.h"
#import "RBCoreDataManagerDelegate.h"

@interface RBCoreDataManager : RBSingleton <RBCoreDataManagerDelegate> {
    
    // These ivars are included since they have custom accessors.
    NSManagedObjectContext * managedObjectContext;
    NSManagedObjectModel * managedObjectModel;
    NSPersistentStoreCoordinator * persistentStoreCoordinator;
    id<RBCoreDataManagerDelegate> delegate;
}

/**
 * The default MOC. Should only be accessed on the main thread.
 */
@property (nonatomic, retain, readonly) NSManagedObjectContext * managedObjectContext;

@property (nonatomic, retain, readonly) NSManagedObjectModel * managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator * persistentStoreCoordinator;

/**
 * The delegate for the manager. This should be set when the application 
 * launches and should not ever be changed. If the delegate is not set, it 
 * defaults to self.
 */
@property (nonatomic, assign) id<RBCoreDataManagerDelegate> delegate;

/**
 * Returns the shared instance.
 */
+ (RBCoreDataManager *) sharedManager;

/**
 * Saves the default MOC.
 */
- (void)saveContext;

/**
 * Creates an autoreleased MOC. You should create a MOC for everyt thread or 
 * Grand Central Dispatch queue.
 */
- (NSManagedObjectContext *) createMOC;

@end
