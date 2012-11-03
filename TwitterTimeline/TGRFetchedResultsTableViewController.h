//
//  TGRFetchedResultsTableViewController.h
//
//  Created by guille on 27/09/12.
//  Copyright (c) 2012 Guillermo Gonzalez. All rights reserved.
//

//  Based on Standford's CoreDataTableViewController

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface TGRFetchedResultsTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) BOOL ignoreContentChanges;

- (void)performFetch;

@end
