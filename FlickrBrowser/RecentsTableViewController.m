//
//  RecentsTableViewController.m
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

- (NSArray *)sortedTableContentFromModel:(NSArray *)model
{
    // sort according to current criteria: most recently viewed first, only 1 section
    NSArray *section = [[model reverseObjectEnumerator] allObjects];
    return [NSArray arrayWithObject:section];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refresh:nil];
}

-(void)refresh:(id)sender
{
    [super refresh:sender];
    // Reload model
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *recents = [[NSUserDefaults standardUserDefaults] valueForKey:RECENTS_KEY];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.view.hidden) return;
            [self.spinner stopAnimating];
            self.model = recents;
        });
    });
    dispatch_release(downloadQueue);
}

@end
