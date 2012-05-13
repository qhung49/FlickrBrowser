//
//  Place+Create.m
//  FlickrBrowser
//
//  Created by Hung Mai on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Place+Create.h"
#import "Vacation+Create.h"

@implementation Place (Create)

+(Place *)placeWithName:(NSString *)name ofVacation:(NSString *)vacationName inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@",name];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    Place *place;
    if (!matches)
    {
        NSLog(@"[Place] Error %i",error.code);
    }
    else if ([matches count]>1) {
        NSLog(@"Duplicate place");
    }
    else if ([matches count]==1) {
        place = [matches lastObject];
    }
    else {
        place = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:context];
        place.name = name;
        place.dateAdded = [NSDate dateWithTimeIntervalSinceNow:0];
        place.vacation = [Vacation vacationWithName:vacationName inManagedObjectContext:context];
    }
    
    return place;
}

@end
