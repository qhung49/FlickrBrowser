//
//  Photo+Flickr.h
//  FlickrBrowser
//
//  Created by Hung Mai on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)flickrInfo ofVacationName:(NSString *)vacationName
        inManagedObjectContext:(NSManagedObjectContext *)context;

@end
