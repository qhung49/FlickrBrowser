//
//  GeneralTableViewController_SubClass.h
//  FlickrBrowser
//
//  Created by Hung Mai on 26/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GeneralTableViewController.h"

@interface GeneralTableViewController (SubClass)

- (NSArray *) sortedTableContentFromModel:(NSArray *)model;
- (void)refresh:(id)sender;

@end
