//
//  VacationPlaceTableViewController.m
//  FlickrBrowser
//
//  Created by Hung Mai on 8/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VacationPlaceTableViewController.h"
#import "VacationPhotoTableViewController.h"
#import "VacationHelper.h"
#import "Place.h"

@interface VacationPlaceTableViewController ()

@property (nonatomic,strong) UIManagedDocument *database;
- (void)setupFetchedResultsController;

@end

@implementation VacationPlaceTableViewController

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
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateAdded" ascending:YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.database.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Place Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // ask NSFetchedResultsController for the NSMO at the row in question
    Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // Then configure the cell using it ...
    cell.textLabel.text = place.name;
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Photo List"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [segue.destinationViewController setTitle:place.name];
        [segue.destinationViewController setPlace:place];
    }
}

@end
