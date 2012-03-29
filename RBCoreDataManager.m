
//
// RBCoreDataManager.m
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

#import "RBCoreDataManager.h"
#import "RBManagedObjectContext.h"

#if defined(__BLOCKS__) && RBCDM_USE_LOCKLESS_EXCLUSION
#import "GCD+RBExtras.h"
#endif

static RBCoreDataManager * _defaultManager = nil;


@interface RBCoreDataManager () {
@private
    NSManagedObjectContext * _managedObjectContext;
    NSManagedObjectModel * _managedObjectModel;
    NSPersistentStoreCoordinator * _persistentStoreCoordinator;
    dispatch_queue_t _defaultMOCQueue;
    id<RBCoreDataManagerDelegate> __unsafe_unretained _delegate;
}

/**
 * The default MOC. Should only be accessed on the main thread.
 */
@property (nonatomic, strong, readwrite) NSManagedObjectContext * managedObjectContext;

/**
 * Returns a URL that points to the documents directory.
 */
- (NSURL *)applicationDocumentsDirectory;

/**
 * Returns the app's name, if one can be found. A default name is returned if a 
 * name can't be found. 
 */
- (NSString *)appName;

#if defined(__BLOCKS__) && RBCDM_USE_LOCKLESS_EXCLUSION

/**
 * A serial quueue used to serialize all requests to the default MOC.
 */
@property (nonatomic, assign) dispatch_queue_t defaultMOCQueue;

#endif

- (void)safelyInitializeObject:(id)object withBlock:(dispatch_block_t)block;

@end


@implementation RBCoreDataManager

@synthesize managedObjectModel         = _managedObjectModel;
@synthesize managedObjectContext       = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize delegate                   = _delegate;
@synthesize defaultMOCQueue            = _defaultMOCQueue;

- (void)saveContext {
    
    [self accessDefaultMOCSyncChecked:^(NSManagedObjectContext * moc) {
        
        NSError * error = nil;
        
        if ([moc hasChanges] && ![moc save:&error]) {
            // !!!: Replace this implementation with code to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }];
}

- (NSManagedObjectContext *)createMOC {
    return [[RBManagedObjectContext alloc] initWithStoreCoordinator:[self persistentStoreCoordinator]];
}

- (NSString *)appName {
    
    NSString * appName = [[NSBundle mainBundle] bundleIdentifier];
    NSArray * comps = [appName componentsSeparatedByString:@"."];
    appName = [comps lastObject];
    
    if (!appName || [appName length] == 0 || [appName isEqualToString:@"*"])
        appName = @"Default";
    
    return appName;
}

- (void)safelyInitializeObject:(id)object withBlock:(dispatch_block_t)block {
    if (!object) {
        @synchronized(self) {
            if (!object) block();
        }
    }
}


#pragma mark - Lockless Exclusion Accessors

#if defined(__BLOCKS__) && RBCDM_USE_LOCKLESS_EXCLUSION

- (dispatch_queue_t)defaultMOCQueue {
    
    if (!_defaultMOCQueue) {
        @synchronized(self) {
            if (!_defaultMOCQueue)
                _defaultMOCQueue = dispatch_queue_create("com.RobertBrown.DefaultMOCQueue", NULL);
        }
    }
    
    return _defaultMOCQueue;
}

- (void)accessDefaultMOCSyncChecked:(RBMOCBlock)block {
    
    dispatch_sync_checked([self defaultMOCQueue], ^{
        block([self managedObjectContext]);
    });
}

- (void)accessDefaultMOCAsync:(RBMOCBlock)block {
    
    dispatch_async([self defaultMOCQueue], ^{
        block([self managedObjectContext]);
    });
}

#endif


#pragma mark - RBCoreDataManagerDelegateMethods

- (id<RBCoreDataManagerDelegate>)delegate {
    
    if (!_delegate)
        return self;
    
    return _delegate;
}

- (BOOL)shouldUseAutomaticLightweightMigration {
    return YES;
}

- (NSString *)modelName {
    return [self appName];
}

- (NSString *)modelExtension {
    return @"momd";
}

- (NSString *)persistentStoreName {
    return [NSString stringWithFormat:@"%@.sqlite", [self appName]];
}

- (NSString *)persistentStoreType {
    return NSSQLiteStoreType;
}

- (NSString *)defaultStoreName {
    return nil;
}


#pragma mark - Core Data stack

/**
 * Returns the managed object context for the application.
 * If the context doesn't already exist, it is created and bound to the 
 * persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    [self safelyInitializeObject:_managedObjectContext withBlock:^{
        NSPersistentStoreCoordinator * coordinator = [self persistentStoreCoordinator];
        
        if (!coordinator) {
            // !!!: Handle this error better.
            NSLog(@"Error creating coordinator.");
            abort();
        }
        
        _managedObjectContext = [[RBManagedObjectContext alloc] initWithStoreCoordinator:coordinator];
    }];
    
    return _managedObjectContext;
}

/**
 * Returns the managed object model for the application.
 * If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    [self safelyInitializeObject:_managedObjectModel withBlock:^{
        NSURL * modelURL = [[NSBundle mainBundle] URLForResource:[[self delegate] modelName]
                                                   withExtension:[[self delegate] modelExtension]];
        if (!modelURL)
            NSAssert2(NO, 
                      @"No MOM file found named: %@.%@ in the main bundle. "
                      "Did you specify the right filename in -modelName and -modelExtension? "
                      "If you are using a custom delegate, be aware that XIBs and UIStoryboards "
                      "are inflated before -application:didFinishLaunchingWithOptions: is called. ", 
                      [[self delegate] modelName], 
                      [[self delegate] modelExtension]);
        
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
        if (!_managedObjectModel) {
            NSAssert1(NO, 
                      @"MOM file could not be read from file at path: %@. "
                      "Did change your model without migrating? "
                      "Try deleting your app and cleaning your build. "
                      "You may need to restart Xcode if it is in an inconsistent state. ", 
                      modelURL);
        }
    }];
    
    return _managedObjectModel;
}

/**
 * Returns the persistent store coordinator for the application.
 * If the coordinator doesn't already exist, it is created and the application's 
 * store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    [self safelyInitializeObject:_persistentStoreCoordinator withBlock:^{
        NSURL * storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[[self delegate] persistentStoreName]];
        
        NSError * error = nil;
        NSFileManager * fileManager = [NSFileManager new];
        
        // !!!: Be sure to create a new default database if the MOM file is ever changed.
        
        // If there is no previous database, then a default one is used (if any).
        if (![fileManager fileExistsAtPath:[storeURL path]] && [[self delegate] defaultStoreName]) {
            
            NSURL * defaultStoreURL = [[NSBundle mainBundle] URLForResource:[[self delegate] defaultStoreName]
                                                              withExtension:nil];
            
            // Copies the default database from the main bundle to the Documents directory.
            [fileManager copyItemAtURL:defaultStoreURL
                                 toURL:storeURL
                                 error:&error];
            if (error) {
                // !!!: Handle the error here.
                NSLog(@"Error copying seed database: %@", [error localizedDescription]);
                
                // Resets the error.
                error = nil;
            }
        }
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        
        NSDictionary * options = nil;
        
        if ([self shouldUseAutomaticLightweightMigration]) {
            // Automatically migrates the model when there are small changes.
            options = [NSDictionary dictionaryWithObjectsAndKeys:
                       [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                       [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                       nil];
        }
        
        NSPersistentStore * store = [_persistentStoreCoordinator addPersistentStoreWithType:[[self delegate] persistentStoreType]
                                                                              configuration:nil 
                                                                                        URL:storeURL 
                                                                                    options:options 
                                                                                      error:&error];
        if (!store) {
            // !!!: Handle this error better for your application.
            NSLog(@"Unable to create persistent store. "
                  "If you are in development, you probably just need to delete your app and clean your build. "
                  "If you are in production, you need to handle migration properly. ");
            abort();
        } 
    }];
    
    return _persistentStoreCoordinator;
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

+ (RBCoreDataManager *)sharedManager {
    return [self defaultManager];
}

+ (RBCoreDataManager *)defaultManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultManager = [RBCoreDataManager new];
    });
    
    return _defaultManager;
}

@end
