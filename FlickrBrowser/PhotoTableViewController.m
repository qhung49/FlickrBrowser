//
//  PhotoTableViewController.m
//  FlickrBrowser
//
//  Created by Hung Mai on 14/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"

@interface PhotoTableViewController ()

@end

@implementation PhotoTableViewController

#pragma mark Getters/Setters

#pragma mark GeneralTableViewController

- (NSArray *)sortedTableContentFromModel
{
    // sort according to current criteria: alphabetical, only 1 section
    NSArray *section = [self.model sortedArrayUsingComparator:^(id obj1, id obj2) {
        NSString *s1 = [obj1 valueForKeyPath:@"description._content"];
        NSString *s2 = [obj2 valueForKeyPath:@"description._content"];
        return [s1 compare:s2 options:NSCaseInsensitiveSearch];
    }];
    return [NSArray arrayWithObject:section];
}

#pragma mark UIViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender 
{
    if ([segue.identifier isEqualToString:@"Display Photo"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSDictionary *photo = [[self.tableContent objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        NSURL *url = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge];
        [segue.destinationViewController setPhotoURL:url];
        [segue.destinationViewController setTitle:[[sender textLabel] text]];
    }
}

#pragma mark UITableViewController

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.tableContent objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Photo Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *photo = [[self.tableContent objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([[photo valueForKey:@"title"] isEqualToString:@""])
    {
        if ([[photo valueForKeyPath:@"description._content"] isEqualToString:@""])
        {
            cell.textLabel.text = @"No Title";
        }
        else
        {
            cell.textLabel.text = [photo valueForKeyPath:@"description._content"];
        }
    }
    else
    {
        cell.textLabel.text = [photo valueForKey:@"title"];
    }
    
    cell.detailTextLabel.text = [photo valueForKeyPath:@"description._content"];

    return cell;
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
    // add to defaults
    NSDictionary *photo = [[self.tableContent objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    NSMutableArray* recents = [[[NSUserDefaults standardUserDefaults] objectForKey:RECENTS_KEY] mutableCopy];
    if (!recents) recents = [NSMutableArray array];
    
    int index = 0;
    while (index<[recents count])
    {
        NSDictionary *item = [recents objectAtIndex:index];
        NSString *idItem = [item valueForKey:@"id"];
        if ([idItem isEqualToString:[photo valueForKey:@"id"]])
        {
            [recents removeObject:item];
        }
        else {
            index++;
        }
    }
    
    [recents addObject:photo];
    [[NSUserDefaults standardUserDefaults] setObject:recents forKey:RECENTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
