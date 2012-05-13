//
//  Tag+Create.h
//  FlickrBrowser
//
//  Created by Hung Mai on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tag.h"

@interface Tag (Create)

+ (Tag *)tagWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;


@end
