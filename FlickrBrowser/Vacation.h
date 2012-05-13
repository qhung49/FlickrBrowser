//
//  Vacation.h
//  FlickrBrowser
//
//  Created by Hung Mai on 8/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place;

@interface Vacation : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Place *places;

@end
