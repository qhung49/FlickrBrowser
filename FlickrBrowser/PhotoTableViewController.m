//
//  PhotoTableViewController.m
//  FlickrBrowser
//
//  Created by Hung Mai on 14/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoTableViewController.h"
#import "GeneralTableViewController+SubClass.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"

@interface PhotoTableViewController ()

- (void)updatePhotoViewController:(PhotoViewController *)photoVC withSelectedIndexPath:(NSIndexPath *)indexPath andTitle:(NSString *)title;

@end

@implementation PhotoTableViewController

#pragma mark UIViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender 
{
    if ([segue.identifier isEqualToString:@"Display Photo"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        PhotoViewController *photoVC = ([segue.destinationViewController isKindOfClass:[PhotoViewController class]]) ? segue.destinationViewController : nil;
        [self updatePhotoViewController:photoVC withSelectedIndexPath:indexPath andTitle:[[sender textLabel] text]];
    }
}

#pragma mark PhotoTableViewController

- (void)updatePhotoViewController:(PhotoViewController *)photoVC withSelectedIndexPath:(NSIndexPath *)indexPath andTitle:(NSString *)title
{
    NSDictionary *photo = [[self.tableContent objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSURL *url = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatOriginal];
    
    // original format not available, fall back to large
    if (!url) url = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge];
    [photoVC setTitle:title];
    [photoVC setPhotoURL:url];
}

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
    if ([[photo valueForKey:FLICKR_PHOTO_TITLE] isEqualToString:@""])
    {
        if ([[photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] isEqualToString:@""])
        {
            cell.textLabel.text = @"No Title";
        }
        else
        {
            cell.textLabel.text = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        }
    }
    else
    {
        cell.textLabel.text = [photo valueForKey:FLICKR_PHOTO_TITLE];
    }
    
    cell.detailTextLabel.text = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];

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
        NSString *idItem = [item valueForKey:FLICKR_PHOTO_ID];
        if ([idItem isEqualToString:[photo valueForKey:FLICKR_PHOTO_ID]])
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
    
    // in case of iPad, set master view controller
    PhotoViewController *photoVC = [self.splitViewController.viewControllers lastObject];
    if (photoVC)
    {
        [self updatePhotoViewController:photoVC 
                  withSelectedIndexPath:indexPath 
                               andTitle:[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text];
    }
}

@end
