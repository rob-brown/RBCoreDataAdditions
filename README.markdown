#RBCoreDataAdditions

##Summary
When building Core Data applications, the templates always put the central Core Data code in the app delegate. This has some problems:

 1. The template's Core Data additions to the app delegate are not part of the app delegate API. This means that you need to request the add delegate, type cast it to your specific app delegate, and make your Core Data calls. This does not create portable code and is terrible design. Anytime you copy your Core Data code to another project, you have to change all of your typecasts. 
 
 2. You may create an app that doesn't have Core Data at first, but later decide to add it. `RBCoreDataAdditions` can be dropped in your app and immediately gives you everything the template does. 
 
 3. The code that is generated is not thread safe. You are left to work out how you want to handle thread safety. Typically it's the exact same technique everytime. 
 
 4. In the template, automatic, lightweight migration is off by default, but is frequently used.
 
In response, `RBCoreDataAdditions` remedies each of these problems:

 1. The Core Data functionality is extracted from the app delegate template into one class that has a well-defined API.
 
 2. `RBCoreDataAdditions` is designed to be dropped into any existing project with the least amount of resistance. Once you add it to your project, you can immediately start creating your Managed Object Model. 
 
 3. `RBCoreDataAdditions` adds standard, lockless thread-safety through context merge notifications. 
 
 4. Automatic, lightweight migration is turned on by default.

On top of all this, by having this code in a centralized location, adding a feature here gives that feature to everyone else. You could never do this with your app delegates.

##Dependencies
`RBCoreDataAdditions` requires Core Data, obviously. It also requires my singleton class [`RBSingleton`][1].

`RBCoreDataAdditions` is written for iOS 3.0+ support.

##Extras

`RBCoreDataAdditions` does *not* depend on my `NSManagedObject+RBExtras` class, but you may find it useful. You can find it in my [RBCategories repository][2]. 

You may also be interested in my [`RBReporter`][3] class. It is great for logging and repoprting Core Data errors.

##How To use
`RBCoreDataAdditions` is meant to be dropped into your app with little effort on your part. If you want to customize the name of your persistent store files and MOM files, then you can change those options in `RBCoreDataManager.m`. Here are the options that you can edit:

```objective-c
/// The name of your Managed Object Model file (without extenstion).
NSString * const kModelName = @"Model";

/// The extension of your Managed Object Model file (typically @"momd" or @"mom").
NSString * const kModelExtension = @"momd";

/// The name of your persistent store file, if applicable.
NSString * const kPersistentStoreName = @"PersistentStore.sqlite";
```

It is assumed that you are going to use the `NSSQLiteStoreType`, but you can also change that where the NSPersistenStoreCoordinator is created.

```objective-c
[persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType  // You can change the store type here.
                                	     configuration:nil 
                                                   URL:storeURL 
                                               options:options 
                                                 error:&error];
```

If you are building a single-threaded application, then you can do all of your operations on the default managed object context. Otherwise, you will need to create a new managed object context for each thread (see example below).

```objective-c
NSManagedObjectContext * moc = [[RBCoreDataManager sharedManager] createMoc];

// Perform some Core Data operations.

NSError * error = nil;

if (![moc save:&error]) {
	// Handle the error.
}
```

You can perform any operations on a new MOC without worrying about thread safety. When you save the context, all of the merging will be handled automatically. If you decide you don't want to keep the changes you made, you can throw out the MOC without affecting any other thread's MOCs. 

Alternatively, you can create an `NSManagedObjectContext` for each Grand Central Dispatch serial queue. The queue itself will act as the "lock" for the MOC. 

Errors, such as migration errors, are not handled in `RBCoreDataManager`. That's up to you to handle according to your needs. 

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

  [1]: https://gist.github.com/1116294
  [2]: https://github.com/rob-brown/RBCategories
  [3]: https://github.com/rob-brown/RBBugReporter