//
//  TopPlacesTableViewController.m
//  FlickrBrowser
//
//  Created by Hung Mai on 14/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceTableViewController.h"
#import "FlickrFetcher.h"
#import "GeneralTableViewController+SubClass.h"
#import "PhotoAtPlaceTableViewController.h"
#import "MapViewController.h"

@interface PlaceTableViewController ()

// format of place: city, state, country
- (NSString *) countryNameFromPlaceString:(NSString *)place;

@end

@implementation PlaceTableViewController

#pragma mark Getters/Setters

#pragma mark PlaceTableViewController
@synthesize spinner;

- (NSString *)countryNameFromPlaceString:(NSString *)place
{
    NSArray *chunks = [place componentsSeparatedByString:@", "];
    return [[chunks lastObject] copy];
}

#pragma mark PhotoTableViewController

- (NSArray *)sortedTableContentFromModel:(NSArray *)model
{
    /*
     // sort according to current criteria: alphabetical, only 1 section
     NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"_content" 
     ascending:YES
     selector:@selector(localizedCaseInsensitiveCompare:)];
     NSArray *section = [self.model sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]];
     return [NSArray arrayWithObject:section];
     */
    // sort according to current criteria: section is by contry, cell is by name
    NSArray *sortedModel = [model sortedArrayUsingComparator:^(id obj1, id obj2) {
        NSString *s1 = [obj1 valueForKeyPath:FLICKR_PLACE_NAME];
        NSString *s2 = [obj2 valueForKeyPath:FLICKR_PLACE_NAME];
        NSString *country1 = [self countryNameFromPlaceString:s1];
        NSString *country2 = [self countryNameFromPlaceString:s2];
        NSComparisonResult compare1 = [country1 compare:country2 options:NSCaseInsensitiveSearch];
        if (compare1 == NSOrderedSame) return [s1 compare:s2 options:NSCaseInsensitiveSearch];
        else return compare1;
    }];
    
    NSMutableArray *result = [NSMutableArray array];
    NSMutableArray *currentSectionArray = [NSMutableArray array];
    for (NSDictionary *place in sortedModel)
    {
        if ([currentSectionArray count]==0) // new section
        {
            [currentSectionArray addObject:place];
        }
        else {
            NSString *lastPlace = [[currentSectionArray lastObject] valueForKey:FLICKR_PLACE_NAME];
            NSString *lastCountry = [self countryNameFromPlaceString:lastPlace];
            if ([lastCountry isEqualToString:[self countryNameFromPlaceString:[place valueForKey:FLICKR_PLACE_NAME]]])
            {
                [currentSectionArray addObject:place];
            }
            else {
                [result addObject:[currentSectionArray copy]];
                currentSectionArray = [NSMutableArray array];
                [currentSectionArray addObject:place];
            }
        }
    }
    return result;
}

- (void)refresh:(id)sender 
{
    [super refresh:sender];
    // Reload model
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *places = [FlickrFetcher topPlaces];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
            self.model = places;
        });
    });
    dispatch_release(downloadQueue);
}

#pragma mark UITableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refresh:nil];
}

- (void)viewDidUnload {
    [self setSpinner:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender 
{
    if ([segue.identifier isEqualToString:@"Show Photo List"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSDictionary *place = [[self.tableContent objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        NSString *newTitle = [[sender textLabel] text];
        [segue.destinationViewController setTitle:newTitle];
        [segue.destinationViewController setPlace:place];
    }
    else if ([segue.identifier isEqualToString:@"Show Map"]) {
        [segue.destinationViewController setAnnotationsArePhoto:NO];
        [segue.destinationViewController setTitle:@"Map"];
        [segue.destinationViewController setModel:self.model];
    }
}

#pragma mark - UITableViewDataSource

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
    static NSString *CellIdentifier = @"Top Places Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *place = [[self.tableContent objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *placeName = [place objectForKey:FLICKR_PLACE_NAME];
    NSDictionary *cityState = [FlickrFetcher cityAndStateFromPlaceName:placeName];    
    cell.textLabel.text = [cityState objectForKey:@"city"];
    cell.detailTextLabel.text = [cityState objectForKey:@"state"];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self countryNameFromPlaceString:[[[self.tableContent objectAtIndex:section] lastObject] valueForKey:FLICKR_PLACE_NAME]] copy];
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
