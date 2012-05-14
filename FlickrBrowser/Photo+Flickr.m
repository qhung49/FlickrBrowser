//
//  Photo+Flickr.m
//  FlickrBrowser
//
//  Created by Hung Mai on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Place+Create.h"
#import "Tag+Create.h"

@implementation Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)flickrInfo ofVacationName:(NSString *)vacationName
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", [flickrInfo objectForKey:FLICKR_PHOTO_ID]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    }
    if (!matches)
    {
        NSLog(@"[Photo] Error %i",error.code);
    }
    else if ([matches count]>1) {
        NSLog(@"Duplicate photo");
    }
    else if ([matches count] == 0) {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.unique = [flickrInfo objectForKey:FLICKR_PHOTO_ID];
        photo.title = [flickrInfo objectForKey:FLICKR_PHOTO_TITLE];
        photo.subtitle = [flickrInfo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.photoURL = [[FlickrFetcher urlForPhotoDisplay:flickrInfo] absoluteString];
        photo.place = [Place placeWithName:[flickrInfo objectForKey:FLICKR_PHOTO_PLACE_NAME] ofVacation:vacationName inManagedObjectContext:context];
        NSString *tags = [flickrInfo objectForKey:FLICKR_TAGS];
        NSLog(@"tags = %@",tags);
        NSArray *tagsArray = [tags componentsSeparatedByString:@" "];
        for (NSString *tagString in tagsArray) {
            NSString *tagCapitalized = [tagString capitalizedString];
            if ([tagCapitalized rangeOfString:@":"].location == NSNotFound) {
                [photo addTagsObject:[Tag tagWithName:tagCapitalized inManagedObjectContext:context]];
            }
        }
    } 
    else {
        photo = [matches lastObject];
    }
    
    return photo;
}

@end
