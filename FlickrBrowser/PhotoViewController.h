//
//  PhotoViewController.h
//  FlickrBrowser
//
//  Created by Hung Mai on 14/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

@interface PhotoViewController : UIViewController <UISplitViewControllerDelegate>

@property (nonatomic,strong) NSDictionary *photo;
@property (nonatomic,strong) Photo *photoInDatabase;

@end
