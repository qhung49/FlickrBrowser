//
//  VacationTagTableViewController.m
//  FlickrBrowser
//
//  Created by Hung Mai on 8/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VacationTagTableViewController.h"
#import "VacationPhotoTableViewController.h"
#import "VacationHelper.h"
#import "Tag.h"

@interface VacationTagTableViewController ()

@property (nonatomic,strong) UIManagedDocument *database;
- (void)setupFetchedResultsController;

@end

@implementation VacationTagTableViewController

@synthesize vacation = _vacation;
@synthesize database = _database;

-(void)setVacation:(NSString *)vacation
{
    _vacation = vacation;
    [VacationHelper openVacation:vacation usingBlock:^(UIManagedDocument *database) {
        [database.managedObjectContext performBlock:^{
            self.database = database;
            [self setupFetchedResultsController];
        }];
    }];
    
}

- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.database.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Tag Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // ask NSFetchedResultsController for the NSMO at the row in question
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // Then configure the cell using it ...
    cell.textLabel.text = tag.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photos", [tag.photos count]];
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Photo List"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [segue.destinationViewController setTitle:tag.name];
        [segue.destinationViewController setPhotoTag:tag];
    }
}

@end
