//
//  Vacation+Create.m
//  FlickrBrowser
//
//  Created by Hung Mai on 8/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Vacation+Create.h"

@implementation Vacation (Create)

+ (Vacation *)vacationWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Vacation"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@",name];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    Vacation *vacation;
    if (!matches)
    {
        NSLog(@"[Vacation] Error %i",error.code);
    }
    else if ([matches count]>1) {
        NSLog(@"Duplicate vacation");
    }
    else if ([matches count]==1) {
        vacation = [matches lastObject];
    }
    else {
        vacation = [NSEntityDescription insertNewObjectForEntityForName:@"Vacation" inManagedObjectContext:context];
        vacation.name = name;
    }
    
    return vacation;
}

@end
