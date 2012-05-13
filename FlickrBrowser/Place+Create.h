//
//  Place+Create.h
//  FlickrBrowser
//
//  Created by Hung Mai on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Place.h"

@interface Place (Create)

+ (Place *)placeWithName:(NSString *)name ofVacation:(NSString *)vacationName inManagedObjectContext:(NSManagedObjectContext *)context;

@end
