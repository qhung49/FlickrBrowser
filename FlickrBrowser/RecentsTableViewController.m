//
//  FlickrBrowserSecondViewController.m
//  FlickrBrowser
//
//  Created by Hung Mai on 14/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecentsTableViewController.h"

@interface RecentsTableViewController ()

@end

@implementation RecentsTableViewController

#pragma mark GeneralTableViewController

- (NSArray *)sortedTableContentFromModel
{
    // sort according to current criteria: alphabetical, only 1 section
    NSArray *section = [[self.model reverseObjectEnumerator] allObjects];
    return [NSArray arrayWithObject:section];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Get model from defaults
    self.model = [[NSUserDefaults standardUserDefaults] valueForKey:RECENTS_KEY];
    [self.tableView reloadData];
}

@end
