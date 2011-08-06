//
//  RBCoreDataManager.m
//
//  Created by Robert Brown on 7/8/11.
//  Copyright 2011 Robert Brown. All rights reserved.
//

#import "RBCoreDataManager.h"
#import "RBManagedObjectContext.h"

static RBCoreDataManager * sharedManager = nil;

/// The name of your Managed Object Model file (without extenstion).
NSString * const kModelName = @"AboutOne";

/// The extension of your Managed Object Model file (typically @"momd" or @"mom").
NSString * const kModelExtension = @"momd";

/// The name of your persistent store file, if applicable.
NSString * const kPersistentStoreName = @"AboutOne.sqlite";


@interface RBCoreDataManager ()

/**
 * Returns a URL that points to the documents directory.
 */
- (NSURL *)applicationDocumentsDirectory;

@end


@implementation RBCoreDataManager

@synthesize managedObjectModel, managedObjectContext, persistentStoreCoordinator;

- (void)saveContext {
    
    NSError * error = nil;
    NSManagedObjectContext * moc = [self managedObjectContext];
    
    if (moc != nil) {
        
        if ([moc hasChanges] && ![moc save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

- (NSManagedObjectContext *) createMOC {
    return [[[RBManagedObjectContext alloc] initWithStoreCoordinator:[self persistentStoreCoordinator]] autorelease];
}


#pragma mark - Core Data stack

/**
 * Returns the managed object context for the application.
 * If the context doesn't already exist, it is created and bound to the 
 * persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator * coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        managedObjectContext = [[RBManagedObjectContext alloc] initWithStoreCoordinator:coordinator];
    }
    
    return managedObjectContext;
}

/**
 * Returns the managed object model for the application.
 * If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    
    NSURL * modelURL = [[NSBundle mainBundle] URLForResource:kModelName withExtension:kModelExtension];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    
    return managedObjectModel;
}

/**
 * Returns the persistent store coordinator for the application.
 * If the coordinator doesn't already exist, it is created and the application's 
 * store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL * storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kPersistentStoreName];
    
    NSError * error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    // Automatically migrates the model when there are small changes.
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                              [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, 
                              nil];
    [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType  // You can change the store type here.
                                               configuration:nil 
                                                         URL:storeURL 
                                                     options:options 
                                                       error:&error];
    if (error) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator;
}


#pragma mark - Application's Documents directory

/**
 * Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory 
                                                   inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - Singleton methods

+ (RBCoreDataManager *) sharedManager {
    
    @synchronized(self) {
        
        if (!sharedManager) {
            sharedManager = [super sharedInstance];
        }
    }
    
    return sharedManager;
}

@end
