//
//  RBManagedObjectContext.m
//  StatCollector
//
//  Created by Robert Brown on 5/16/11.
//  Copyright 2011 Robert Brown. All rights reserved.
//

#import "RBManagedObjectContext.h"


@implementation RBManagedObjectContext

- (id)initWithStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator {
    
    NSAssert(nil != coordinator, @"Nil persistent store coordinator.");
    
    if ((self = [super init])) {
        
        [self setPersistentStoreCoordinator:coordinator];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(mergeChangesFromContextDidSaveNotification:) 
                                                     name:NSManagedObjectContextDidSaveNotification 
                                                   object:nil];
    }
    
    return self;
}

- (void)mergeChangesFromContextDidSaveNotification:(NSNotification *)notification {
    
    // Put a break point here to watch when contexts are merging.
    [super mergeChangesFromContextDidSaveNotification:notification];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
