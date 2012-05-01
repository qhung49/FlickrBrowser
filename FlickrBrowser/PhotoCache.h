//
//  PhotoCache.h
//  FlickrBrowser
//
//  Created by Hung Mai on 30/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoCache : NSObject

@property (nonatomic,strong) NSURL *url;
@property (nonatomic,readonly) UIImage *image;

@end
