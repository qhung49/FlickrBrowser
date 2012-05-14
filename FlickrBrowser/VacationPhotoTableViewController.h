//
//  VacationPhotoTableViewController.h
//  FlickrBrowser
//
//  Created by Hung Mai on 8/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Place.h"
#import "Tag.h"

@interface VacationPhotoTableViewController : CoreDataTableViewController

@property (nonatomic,strong) Place *place;
@property (nonatomic,strong) Tag *photoTag;

@end
