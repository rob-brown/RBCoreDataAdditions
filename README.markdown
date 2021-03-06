#RBCoreDataAdditions

##Summary
When building Core Data applications, the Xcode template always puts the central Core Data code in the app delegate. This has some problems:

 1. The template's Core Data additions to the app delegate are not part of the app delegate API. This means that you need to request the add delegate, type cast it to your specific app delegate, and make your Core Data calls. This does not create portable code and is terrible design. Anytime you copy your Core Data code to another project, you have to change all of your typecasts. 
 
 2. You may create an app that doesn't have Core Data at first, but later decide to add it. The Xcode template can only be applied when first creating a project.
 
 3. The code that is generated is not thread safe. You are left to work out how you want to handle thread safety. Typically it's the exact same technique everytime. 
 
 4. In the template, automatic, lightweight migration is off by default, but lightweight migration is frequently used.
 
In response, `RBCoreDataAdditions` remedies each of these problems:

 1. The Core Data functionality is extracted from the app delegate template into one class that has a well-defined API.
 
 2. `RBCoreDataAdditions` is designed to be dropped into any existing project with the least amount of resistance. Once you add it to your project, you can immediately start creating your Managed Object Model. 
 
 3. `RBCoreDataAdditions` adds standard, lockless thread-safety through context merge notifications. 
 
 4. Automatic, lightweight migration is turned on by default but you may opt out by changing one line.

On top of all this, by having this code in a centralized location, adding a feature to `RBCoreDataAdditions` distributes that functionality to all code using `RBCoreDataAdditions`. You could never do this with your app delegates.

##Dependencies
`RBCoreDataAdditions` is written for iOS 3.0+ support.

`RBCoreDataAdditions` requires Core Data, obviously. 

If iOS 4.0+ is used, then `RBCoreDataManager` requires my [`GCD+RBExtras`][2] and Grand Central Dispatch (AKA libdispatch). This is done to use a lockless exclusion pattern that I have personally developed. What happens is the default MOC is encapsulated and is inaccessible to outside classes. It can only be accessed by calling `-accessDefaultMOCAsync:` or `-accessDefaultMOCSyncSafe:`. This is to ensure that the default MOC is only accessed on the main thread. This feature and dependency can be removed by defining `RBCDM_USE_LOCKLESS_EXCLUSION` as 0.

##Extras

`RBCoreDataAdditions` does *not* depend on my `NSManagedObject+RBExtras` class, but you may find it useful. You can find it in my [RBCategories repository][2]. 

You may also be interested in my [`RBReporter`][3] class. It is great for logging and reporting Core Data errors.

##How To use
`RBCoreDataAdditions` is meant to be dropped into your app with little effort on your part. If you want to customize the name of your persistent store file, name of MOM file, etc you can do one of the following: 

 1. Subclass `RBCoreDataManager`. 

 2. Create an `RBCoreDataManagerDelegate`. If you take this route, you need to beware a couple things. First, you should set the delegate as soon as possible after launch and never change it. Second, XIBs and UIStoryboards are inflated before `-application:didFinishLaunchingWithOptions:` is called. If you make any calls to `RBCoreDataManager` in your view loading code, then the delegate may not be set yet and will revert to the defaults in `RBCoreDataManager.m`.
 
 3. Modify the delegate calls within `RBCoreDataManager.m`. This is the safest option. However, if you submit a pull request for `RBCoreDataAdditions`, you should not modify the delegate methods in `RBCoreDataManager.m`.
 
Here are the options defined in `RBCoreDataManagerDelegate`:

```objective-c
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

/**
 * Returns the name of a default persistent store in the the main bundle. If 
 * there is no persistent store file, then this file will be copied from the 
 * main bundle to the Documents directory. If you don't want to use a default 
 * store, then return nil.
 */
- (NSString *)defaultStoreName;

@end
```

If you are building a single-threaded application, then you can do all of your operations on the default managed object context. Otherwise, you will need to create a new managed object context for each thread (see example below).

```objective-c
NSManagedObjectContext * moc = [[RBCoreDataManager defaultManager] createMoc];

// Perform some Core Data operations.

NSError * error = nil;

if (![moc save:&error]) {
	// Handle the error.
}
```

You can perform any operations on a new MOC without worrying about thread safety, as long as those operations are performed on the same thread the MOC was created on. When you save the context, all of the merging will be handled automatically. If you decide you don't want to keep the changes you made, you can throw out the MOC without affecting any other thread's MOCs. 

Alternatively, you can create an `NSManagedObjectContext` for each Grand Central Dispatch serial queue. The queue itself will act as the "lock" for the MOC. This technique does not work with concurrent queues.

Errors, such as migration errors, are not handled in `RBCoreDataManager`. That's up to you to handle according to your needs. 

##Other Additions

###RBFetchedResultsTableVC

`RBCoreDataAdditions` includes a table view controller that has an `NSFetchedResultsController` already integrated into it. All you need to do is subclass `RBFetchedResultsTableVC` and override the needed template methods.

 1. `-tableView:cellForRowAtIndexPath:` (Required) Creates a customized cell for your `NSManagedObject` subclass.
 
 2. `-entityName` (Required) The name of the `NSManagedObject` subclass you want to show in the table view.
 
 3. `-sortDescriptors` (Required) The sort descriptors to use to sort your data.

 4. `-tableView:didSelectRowAtIndexPath:` (Optional but highly recommended) Action to perform when tapping a cell.
 
 5. `-predicate` (Optional but highly recommended) The predicate to use to filter the fetched results.
 
 6.  `-batchSize` (Optional) The number of results to fetch per request. The default value is already set for iPhone. If you use `RBCoreDataAdditions` in an iPad app, you will want to increase the batch size.
 
 7. `-cacheName` (Optional) The name to use for the cache. The default is guaranteed to be unique. You should only override this if you want to share a cache between classes or you don't want caching. Return `nil` to disable caching. 
 
 8. `-sectionNameKeyPath` (Optional) The key path to use for sections. The default is `nil`.

##License

`RBCoreDataAdditions` is licensed under the MIT license, which is reproduced in its entirety here:

>Copyright (c) 2011 Robert Brown
>
>Permission is hereby granted, free of charge, to any person obtaining a copy
>of this software and associated documentation files (the "Software"), to deal
>in the Software without restriction, including without limitation the rights
>to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
>copies of the Software, and to permit persons to whom the Software is
>furnished to do so, subject to the following conditions:
>
>The above copyright notice and this permission notice shall be included in
>all copies or substantial portions of the Software.
>
>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
>IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
>FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
>AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
>LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
>OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
>THE SOFTWARE.

  [2]: https://github.com/rob-brown/RBCategories
  [3]: https://github.com/rob-brown/RBBugReporter