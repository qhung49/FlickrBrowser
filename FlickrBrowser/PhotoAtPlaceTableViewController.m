//
//  PhotoAtPlaceTableViewController.m
//  FlickrBrowser
//
//  Created by Hung Mai on 30/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoAtPlaceTableViewController.h"
#import "FlickrFetcher.h"
#import "GeneralTableViewController+SubClass.h"

@implementation PhotoAtPlaceTableViewController

@synthesize place = _place;

#pragma mark Getters/Setters

#pragma mark GeneralTableViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refresh:nil];
}

- (NSArray *)sortedTableContentFromModel:(NSArray *)model
{
    // sort according to current criteria: alphabetical, only 1 section
    NSArray *section = [model sortedArrayUsingComparator:^(id obj1, id obj2) {
        NSString *s1 = [obj1 valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        NSString *s2 = [obj2 valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        return [s1 compare:s2 options:NSCaseInsensitiveSearch];
    }];
    return [NSArray arrayWithObject:section];
}

-(void)refresh:(id)sender
{
    [super refresh:sender];
    // Reload model
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *photos = [FlickrFetcher photosInPlace:self.place maxResults:50];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if (self.view.hidden) return;
            [self.spinner stopAnimating];
            self.model = photos;
        });
    });
    dispatch_release(downloadQueue);
}

@end
