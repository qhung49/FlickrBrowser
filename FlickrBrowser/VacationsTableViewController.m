//
//  VacationsTableViewController.m
//  FlickrBrowser
//
//  Created by Hung Mai on 8/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VacationsTableViewController.h"
#import "VacationStaticTableViewController.h"

@interface VacationsTableViewController ()

@end

@implementation VacationsTableViewController

#pragma mark GeneralTableViewController

- (NSArray *)sortedTableContentFromModel:(NSArray *)model
{
    // sort according to current criteria: alphabetical, only 1 section
    NSArray *section = [model sortedArrayUsingComparator:^(id obj1, id obj2) {
        NSString *s1 = [obj1 lastPathComponent];
        NSString *s2 = [obj2 lastPathComponent];
        return [s1 compare:s2 options:NSCaseInsensitiveSearch];
    }];
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
    dispatch_queue_t downloadQueue = dispatch_queue_create("from file system", NULL);
    dispatch_async(downloadQueue, ^{
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Vacations"];
        NSError *error;
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url 
                                                       includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                          options:NSDirectoryEnumerationSkipsHiddenFiles 
                                                                            error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.view.hidden) return;
            [self.spinner stopAnimating];
            self.model = files;
        });
    });
    dispatch_release(downloadQueue);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.tableContent count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.tableContent objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Vacation Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [[[self.tableContent objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] lastPathComponent];
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Vacation Options"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSURL *url = [[self.tableContent objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        [segue.destinationViewController setTitle:[url lastPathComponent]];
        [segue.destinationViewController setVacation:[url lastPathComponent]];
    }
}

@end
