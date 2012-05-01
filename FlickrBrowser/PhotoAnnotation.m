//
//  FlickrPhotoAnnotation.m
//  Shutterbug
//
//  Created by Hung Mai on 21/4/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "PhotoAnnotation.h"
#import "FlickrFetcher.h"

@implementation PhotoAnnotation

@synthesize photo = _photo;

+(PhotoAnnotation *)annotationForPhoto:(NSDictionary *)photo
{
    PhotoAnnotation *annotation = [[PhotoAnnotation alloc] init];
    annotation.photo = photo;
    return annotation;
}

- (NSString *)title
{
    return [self.photo objectForKey:FLICKR_PHOTO_TITLE];
}

- (NSString *)subtitle
{
    return [self.photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.photo objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.photo objectForKey:FLICKR_LONGITUDE] doubleValue];
    return coordinate;
}

@end
