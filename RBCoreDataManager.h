//
// RBCoreDataManager.h
//
// Copyright (c) 2011 Robert Brown
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "RBSingleton.h"
#import "RBCoreDataManagerDelegate.h"

#define RBCDM_USE_LOCKLESS_EXCLUSION 1

/// A convenient block type to use when creating MOC-accessing blocks.
typedef void(^RBMOCBlock)(NSManagedObjectContext * moc);

@interface RBCoreDataManager : RBSingleton <RBCoreDataManagerDelegate> {
    
    // These ivars are included since they have custom accessors.
    @private
    NSManagedObjectContext * managedObjectContext;
    NSManagedObjectModel * managedObjectModel;
    NSPersistentStoreCoordinator * persistentStoreCoordinator;
    id<RBCoreDataManagerDelegate> delegate;
}

#if !defined(__BLOCKS__) || !RBCDM_USE_LOCKLESS_EXCLUSION

/**
 * The default MOC. Should only be accessed on the main thread.
 */
@property (nonatomic, retain, readonly) NSManagedObjectContext * managedObjectContext;

#endif

/**
 * The data model.
 */
@property (nonatomic, retain, readonly) NSManagedObjectModel * managedObjectModel;

/**
 * The persistent store coordinator. You may have more than one MOC and more 
 * than one persistent store, but you should rarely have more than one 
 * persistent store coordinator.
 */
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

#if defined(__BLOCKS__) && RBCDM_USE_LOCKLESS_EXCLUSION

/**
 * If blocks and GCD are available, then this is the preferred way to access the default MOC (rather than [self managedObjectContext]).
 */
- (void)accessDefaultMOCAsync:(RBMOCBlock)block;

- (void)accessDefaultMOCSyncSafe:(RBMOCBlock)block;

#endif

@end
