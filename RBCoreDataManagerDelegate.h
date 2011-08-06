//
// RBCoreDataManagerDelegate.h
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
