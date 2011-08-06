//
//  RBCoreDataManagerDelegate.h
//  AboutOne
//
//  Created by Robert Brown on 8/5/11.
//  Copyright 2011 Robert Brown. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RBCoreDataManagerDelegate <NSObject>

/**
 * Returns true if you want to use automatic, lightweight migration.
 */
- (BOOL)shouldUseAutomaticLightweightMigration;

/**
 * Returns the filename of the MOM (without extension).
 */
- (NSString *)modelName;

/**
 * The extension to use for the MOM file (typically momd or mom).
 */
- (NSString *)modelExtension;

/**
 * Returns the filename to use for the persistent store.
 */
- (NSString *)persistentStoreName;

/**
 * Returns a string representing a persistent store type. Typically 
 * NSSQLiteStoreType.
 */
- (NSString *)persistentStoreType;

@end
