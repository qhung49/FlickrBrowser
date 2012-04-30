//
//  GeneralTableViewController.h
//  FlickrBrowser
//
//  Created by Hung Mai on 14/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GeneralTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *model;
@property (nonatomic, strong) NSArray *tableContent;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end
