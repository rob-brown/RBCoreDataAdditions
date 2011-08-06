//
//  RBCoreDataManager.h
//
//  Created by Robert Brown on 7/8/11.
//  Copyright 2011 Robert Brown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "RBSingleton.h"

@interface RBCoreDataManager : RBSingleton

@property (nonatomic, retain, readonly) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel * managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator * persistentStoreCoordinator;

+ (RBCoreDataManager *) sharedManager;

- (void)saveContext;
- (NSManagedObjectContext *) createMOC;

@end
