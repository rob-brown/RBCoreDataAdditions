//
// RBFetchedResultsTableVC.m
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

#import "RBFetchedResultsTableVC.h"
#import "RBCoreDataManager.h"
#import "RBReporter.h"


@interface RBFetchedResultsTableVC ()

@property (nonatomic, retain, readwrite) NSFetchedResultsController * fetchedResultsController;

@property (nonatomic, retain, readwrite) NSManagedObjectContext * context;

/**
 * Required method, must be overriden by subclasses. Return the name of the entity
 * you want to display in the tableview.
 */
- (NSString *)entityName;

/**
 * Returns the predicate to use to filter the fetch.
 */
- (NSPredicate *)predicate;

/**
 * The number of results to return in one fetch. Set to slightly more than one 
 * screen full of content.
 */
- (NSInteger)batchSize;

/**
 * Return any sort descriptors you want to use to sort your data.
 */
- (NSArray *)sortDescriptors;

/**
 * The name to use for a cache. If you don't want to cache your data, then 
 * return nil.
 */
- (NSString *)cacheName;

/**
 * Return the keypath to use for sections. If you don't want to use sections, 
 * return nil.
 */
- (NSString *)sectionNameKeyPath;

@end


@implementation RBFetchedResultsTableVC

@synthesize tableView;
@synthesize fetchedResultsController;
@synthesize context;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        [self setContext:[[RBCoreDataManager sharedManager] createMOC]];
    }
    
    return self;
}


#pragma mark - Memory Management

- (void)dealloc {
    [self setTableView:nil];
    [self setFetchedResultsController:nil];
    [self setContext:nil];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Template methods

- (NSString *)entityName {
    NSAssert1(NO, @"Required method: %@ not overriden.", NSStringFromSelector(@selector(_cmd)));
    return nil;
}

- (NSPredicate *)predicate {
    return nil;
}

- (NSInteger)batchSize {
    return 20;
}

- (NSArray *)sortDescriptors {
    NSAssert1(NO, @"Required method: %@ not overriden.", NSStringFromSelector(@selector(_cmd)));
    return nil;
}

- (NSString *)cacheName {
    return NSStringFromClass([self class]);
}

- (NSString *)sectionNameKeyPath {
    return nil;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert1(NO, @"Required method: %@ not overriden.", NSStringFromSelector(@selector(_cmd)));
    return nil;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
    }   
}
*/

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// Subclasses should override this method.
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    @synchronized(self) {
        
        if (fetchedResultsController)
            return fetchedResultsController;
        
        // Create the fetch request for the entity.
        NSFetchRequest * fetchRequest = [NSFetchRequest new];
        // Edit the entity name as appropriate.
        NSEntityDescription * entity = [NSEntityDescription entityForName:[self entityName]
                                                   inManagedObjectContext:[self context]];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:[self batchSize]];
        [fetchRequest setSortDescriptors:[self sortDescriptors]];
        [fetchRequest setPredicate:[self predicate]];
        
        NSFetchedResultsController * fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                           managedObjectContext:[self context]
                                                                                             sectionNameKeyPath:[self sectionNameKeyPath] 
                                                                                                      cacheName:[self cacheName]];
        fetchController.delegate = self;
        self.fetchedResultsController = fetchController;
        
        [fetchController release];
        [fetchRequest release];
        
        NSError * error = nil;
        if (![fetchedResultsController performFetch:&error]) {
            
            // Uses RBReporter, but you may remove it if you want to handle your errors differently.
            
            [RBReporter logError:error];
            [RBReporter presentAlertWithTitle:@"Unkown Error" 
                                      message:@"Unable to update data listing. Reason unknown."];
        }
    }
    
    return fetchedResultsController;
}    


#pragma mark - Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] 
						  withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] 
						  withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView * aTableView = [self tableView];
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [aTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] 
							 withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [aTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
							 withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [[aTableView dataSource] tableView:aTableView cellForRowAtIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [aTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
							 withRowAnimation:UITableViewRowAnimationFade];
            [aTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
