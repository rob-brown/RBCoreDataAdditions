//
//  RBManagedObjectContext.h
//  StatCollector
//
//  Created by Robert Brown on 5/16/11.
//  Copyright 2011 Robert Brown. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Convenience class used to automatically gain the advantage of merge 
 * notifications without needing to explicitly add and remove them from 
 * NSNotifictionCenter.
 */
@interface RBManagedObjectContext : NSManagedObjectContext

/**
 * Initializes an RBManagedObjectContext with the NSPersistentStoreCoordinator.
 * Also adds itself as an observer for NSManagedObjectContextDidSaveNotifications.
 *
 * @param coordinator. The NSPersistentStoreCoordinator to use with the MOC. 
 * Must not be nil!
 *
 * @return self
 */
- (id)initWithStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator;

@end
