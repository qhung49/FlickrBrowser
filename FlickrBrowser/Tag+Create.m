//
//  Tag+Create.m
//  FlickrBrowser
//
//  Created by Hung Mai on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tag+Create.h"

@implementation Tag (Create)

+ (Tag *)tagWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@",name];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    Tag *tag;
    if (!matches)
    {
        NSLog(@"[Tag] Error %i",error.code);
    }
    else if ([matches count]>1) {
        NSLog(@"Duplicate tag");
    }
    else if ([matches count]==1) {
        tag = [matches lastObject];
    }
    else {
        tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
        tag.name = name;
    }
    
    return tag;
}

@end
