//
//  Vacation+Create.h
//  FlickrBrowser
//
//  Created by Hung Mai on 8/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Vacation.h"

@interface Vacation (Create)

+ (Vacation *)vacationWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;

@end
